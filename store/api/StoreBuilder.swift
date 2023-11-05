import Foundation

class StoreBuilder<Key: Hashable, Network, Local, Output> {
    private var sourceOfTruth: AnySourceOfTruth<Key, Local, Output>? = nil
    private var memoryCache: AnyCache<Key, Output>? = nil
    private var converter: AnyConverter<Network, Local, Output>
    private var fetcher: AnyFetcher<Key, Network>
    private var validator: AnyValidator<Output>? = nil
    
    init(
        fetcher: AnyFetcher<Key, Network>,
        converter: AnyConverter<Network, Local, Output>
    ) {
        self.fetcher = fetcher
        self.converter = converter
    }
    
    func sourceOfTruth(_ sourceOfTruth: AnySourceOfTruth<Key, Local, Output>) -> StoreBuilder{
        self.sourceOfTruth = sourceOfTruth
        return self
    }
    
    func memoryCache(_ memoryCache: AnyCache<Key, Output>) -> StoreBuilder{
        self.memoryCache = memoryCache
        return self
    }
    
    func validator(_ validator: AnyValidator<Output>) -> StoreBuilder{
        self.validator = validator
        return self
    }
    
    func build() -> AnyStore<Key, Output> {
        let streamHandlerImpl = StreamHandlerImpl(fetcher: fetcher, converter: converter, sourceOfTruth: sourceOfTruth, validator: validator, memoryCache: memoryCache)
        let streamHandler = AnyStreamHandler(streamHandlerImpl)
        
        let storeImpl = StoreImpl(streamHandler: streamHandler, sourceOfTruth: sourceOfTruth, memoryCache: memoryCache)
        return AnyStore(storeImpl)
    }
}
