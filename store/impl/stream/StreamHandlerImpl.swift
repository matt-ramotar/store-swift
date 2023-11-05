import Foundation
import Combine

internal class StreamHandlerImpl<Key: Hashable, Network, Local, Output>: StreamHandler {
    private let fetcher: AnyFetcher<Key, Network>
    private let sourceOfTruth: AnySourceOfTruth<Key, Local, Output>?
    private let converter: AnyConverter<Network, Local, Output>
    private let validator: AnyValidator<Output>?
    private let memoryCache: AnyCache<Key, Output>?
    private var locks = Dictionary<Key, NSLock>()
    
    private var cancellables = Dictionary<Key, NSMutableSet>()
    private var subjects = Dictionary<Key, PassthroughSubject<StoreReadResponse<Output>, StoreError>>()
    
    init(
        fetcher: AnyFetcher<Key, Network>,
        converter: AnyConverter<Network, Local, Output>,
        sourceOfTruth: AnySourceOfTruth<Key, Local, Output>? = nil,
        validator: AnyValidator<Output>? = nil,
        memoryCache: AnyCache<Key, Output>? = nil
    ) {
        self.fetcher = fetcher
        self.converter = converter
        self.sourceOfTruth = sourceOfTruth
        self.validator = validator
        self.memoryCache = memoryCache
    }
    
    func stream(request: StoreReadRequest<Key>) -> AnyPublisher<StoreReadResponse<Output>, StoreError> {
        setUpForRequest(request)
        
        // Offload asynchronous work to a background task to return a publisher immediately and send events on it asynchronously as they become available.
        offloadHandlingRequest(request)

        // Immediately return the publisher for the provided key.
        return eraseToAnyPublisher(request.key)
    }
    
    private func setUpForRequest(_ request: StoreReadRequest<Key>) {
        self.cancellables[request.key] = NSMutableSet()
        
        // Init a lock for the provided key if one doesn't already exist.
        if !self.locks.contains(where: {$0.key == request.key}) {
            let lock = NSLock()
            self.locks[request.key] = lock
        }
        
        // Init a `PassthroughSubject` for the provided key if one doesn't already exist.
        if !self.subjects.contains(where: { $0.key == request.key }) {
            let subject = PassthroughSubject<StoreReadResponse<Output>, StoreError>()
            self.subjects[request.key] = subject
        }
    }
    
    private func offloadHandlingRequest(_ request: StoreReadRequest<Key>) {
        Task {
            // Sleep for 1 millisecond to ensure the publisher is returned before an event is sent.
            let sleepDuration = 1 * 1000 * 1000
            try? await Task.sleep(nanoseconds: UInt64(sleepDuration))
            
            do {
                await handleRequest(request)
            }
        }
        
    }
    
    private func handleRequest(_ request: StoreReadRequest<Key>) async {
        if request.skipCaches {
            // If `skipCaches` is requested, bypass the memory cache and source of truth, and fetch from network directly.
            // If `fallBackToSourceOfTruth` is requested, fall back on network failure.
            await handleSkipCaches(request: request)
        } else {
            // First try to get data from the memory cache.
            // If data is found in the memory cache, return it. But if `refresh` is requested, after returning the cached data, fetch from network, write to source of truth, and then also return the refreshed data.
            if let cachedData = await getFromMemoryCache(key: request.key) {
                await handleCachedData(request: request, cachedData: cachedData)
            } else {
                // Next try to get data from the source of truth.
                // If data is found in the source of truth, validate it.
                // If it's valid, return it.
                // But if `refresh` is requested, after returning the valid data from the source of truth, fetch from network, write to source of truth, and then also return the refreshed data.
                // If it's not valid, fetch from network, write to source of truth, and return.
                // If data is not found in the source of truth, fetch from network, write to source of truth, and return.
                await handleSourceOfTruthOrNetworkFetch(request: request)
            }
        }
    }
    
    private func getFromMemoryCache(key: Key) async -> Output? {
        send(.loading(origin: .cache), key: key)
        return memoryCache?.getIfPresent(forKey: key)
    }
    
    private func handleSkipCaches(request: StoreReadRequest<Key>) async {
        await fetchFromNetworkAndWriteToSourceOfTruth(key: request.key, fallBackToSourceOfTruth: request.fallBackToSourceOfTruth)
    }
    
    private func handleCachedData(request: StoreReadRequest<Key>, cachedData: Output) async -> Void {
        await handleOutputDataValidation(request: request, outputData: cachedData, origin: .cache)
    }
    
    private func handleSourceOfTruthOrNetworkFetch(request: StoreReadRequest<Key>) async -> Void {
        send(.loading(origin: .sourceOfTruth), key: request.key)
        
        guard let sourceOfTruth = sourceOfTruth else {
            await fetchFromNetworkAndWriteToSourceOfTruth(key: request.key, fallBackToSourceOfTruth: false)
            return
        }

        let cancellable = sourceOfTruth.read(for: request.key).sink(receiveCompletion: {_ in }, receiveValue: {[weak self] outputData in
            guard let self = self else {
                return
            }
            guard let outputData = outputData else {
                Task { do { await self.fetchFromNetworkAndWriteToSourceOfTruth(key: request.key, fallBackToSourceOfTruth: request.fallBackToSourceOfTruth)}}
                return
            }
            
            Task {
                do {
                    await self.handleOutputDataValidation(request: request, outputData: outputData, origin: .sourceOfTruth)
                }
            }
        })
        
        await requireCancellables(key: request.key).add(cancellable)
    }
    
    private func handleOutputDataValidation(request: StoreReadRequest<Key>, outputData: Output, origin: StoreReadResponseOrigin) async -> Void {
        
        guard let validator = validator else {
            return send(.data(value: outputData, origin: origin), key: request.key)
        }
        
        let cancellable = Task { [weak self] in
            
            let isValid = await validator.isValid(outputData)
            
            if isValid {
                self?.send(.data(value: outputData, origin: origin), key: request.key)
                
                // If refresh is requested, fetch from network, write to source of truth, and return.
                if request.refresh {
                    await self?.fetchFromNetworkAndWriteToSourceOfTruth(key: request.key, fallBackToSourceOfTruth: false)
                }
            } else {
                self?.send(.error(error: .cache(.validationFailed), origin: .cache), key: request.key)
                await self?.fetchFromNetworkAndWriteToSourceOfTruth(key: request.key, fallBackToSourceOfTruth: false)
            }
        }
        
        await requireCancellables(key: request.key).add(cancellable)
    }
    
    func requireRelaySubject(key: Key) -> PassthroughSubject<StoreReadResponse<Output>, StoreError>  {
        return self.subjects[key]!
    }
    
    func requireCancellables(key: Key) async -> NSMutableSet {
        return self.cancellables[key]!
    }
    
    private func fetchFromNetworkAndWriteToSourceOfTruth(key: Key, fallBackToSourceOfTruth: Bool) async {
        send(.loading(origin: .fetcher(name: fetcher.name)), key: key)
        
        let cancellable = fetcher.fetch(key: key).sink(receiveCompletion: {_ in }, receiveValue: { [weak self] value in
            switch (value) {
            case let .data(value, _):
           
                if let self = self {
                    let outputData = self.converter.fromNetworkToOutput(value)
                    
                    Task {
                        do {
                            let _ = await self.write(key: key, value: outputData)
                            self.send(.data(value: outputData, origin: .fetcher(name: self.fetcher.name)), key: key)
                        }
                    }
                }
                
            case let .error(error):
                if let self = self, fallBackToSourceOfTruth {
                    // If `fallBackToSourceOfTruth` requested, try to fall back to the source of truth.
                    Task { do { await self.tryFallBackToSourceOfTruth(key: key, error: .networkError(error))}}
                } else if let self = self {
                    // Otherwise, return the error.
                    let storeError = StoreError.fetcher(.networkError(error))
                    self.send(.error(error: storeError, origin: .fetcher(name: nil)), key: key)
                }
               
            }
        })
        
        await requireCancellables(key: key).add(cancellable)
    }
    
    private func write(key: Key, value: Output) async -> StoreDelegateWriteResult {
        do {
            try await sourceOfTruth?.write(key: key, value: converter.fromOutputToLocal(value))
            memoryCache?.put(value: value, forKey: key)
            return .success
        } catch {
            return .error(StoreDelegateWriteError.exception(error))
        }
    }
    
    private func tryFallBackToSourceOfTruth(key: Key, error: FetcherError) async {
        guard let sourceOfTruth = sourceOfTruth else {
            let response = StoreReadResponse<Output>.error(error: .sourceOfTruth(.nilSelf), origin: .sourceOfTruth)
            return send(response, key: key)
        }
        
        let cancellable = sourceOfTruth.read(for: key).sink(receiveCompletion: {_ in }, receiveValue: {[weak self] outputData in
            guard let self = self else {
                return
            }
            
            guard let outputData = outputData else {
                let response = StoreReadResponse<Output>.error(error: .fetcher(error), origin: .fetcher(name: fetcher.name))
                return send(response, key: key)
            }
            
            Task {
                let isValid = await self.validator?.isValid(outputData) ?? true
                
                if isValid {
                    return self.send(.data(value: outputData, origin: .sourceOfTruth), key: key)
                } else {
                    return self.send(.error(error: .fetcher(error), origin: .fetcher(name: self.fetcher.name)), key: key)
                }
            }
        })
        
        await requireCancellables(key: key).add(cancellable)
    }
    
    private func send(_ response: StoreReadResponse<Output>, key: Key) {
        locks[key]!.withLock {
            requireRelaySubject(key: key).send(response)
        }
    }
    
    private func eraseToAnyPublisher(_ key: Key) -> AnyPublisher<StoreReadResponse<Output>, StoreError> {
        locks[key]!.withLock {
            return requireRelaySubject(key: key).eraseToAnyPublisher()
        }
    }
}

