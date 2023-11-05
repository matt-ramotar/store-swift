import XCTest
import Combine
@testable import store


final class StreamHandlerWithoutSourceOfTruthTests: XCTestCase {
    
    var streamHandler: StreamHandlerImpl<String, TestNetworkDataModel, TestLocalDataModel, TestDataModel>!
    var ttl: Date!
    
    private let syncQueue = DispatchQueue(label: "com.dropbox.ios.store.TestDispatchQueue")

    private func setUpStreamHandler(memoryCache: AnyCache<String, TestDataModel> = CacheBuilder<String, TestDataModel>().build()) {
        let fetcher = FetcherFactory.make({ id in
            let networkData = TestNetworkDataModel(id: id, name: id, title: id, ttl: self.ttl)
            let fetcherResult = FetcherResult.data(value: networkData, fetcherName: nil)
            return Just(fetcherResult).setFailureType(to: StoreError.self).eraseToAnyPublisher()
        })
        
        let converter = ConverterBuilder<TestNetworkDataModel, TestLocalDataModel, TestDataModel>()
            .fromNetworkToOutput({network in
                TestDataModel(id: network.id, name: network.name, title: network.title, ttl: network.ttl)
            })
            .fromOutputToLocal({output in
                TestLocalDataModel(id: output.id, name: output.name, title: output.title, ttl: output.ttl)
            })
            .fromNetworkToLocal({network in
                TestLocalDataModel(id: network.id, name: network.name, title: network.title, ttl: network.ttl)
            })
            .build()
        
        let validator = ValidatorFactory<TestDataModel>.make({ output in output.ttl > Date.now})
        
        streamHandler = StreamHandlerImpl(fetcher: fetcher, converter: converter, validator: validator, memoryCache: memoryCache)
    }

    override func tearDownWithError() throws {
        streamHandler = nil
        try super.tearDownWithError()
    }

    func testStreamFromFreshRequestWithMemoryCache() async throws {
        setUpStreamHandler()
        ttl = Date.distantFuture

        let id = "1"
        let request = StoreReadRequest.fresh(key: id)
        var cancellables = [AnyCancellable]()
        
        let expectedNumberOfResponses = 2
        let expectation = expectation(description: "Correct number of responses")
        let expectedData = TestDataModel(id: id, name: id, title: id, ttl: self.ttl)
        
        let publisher = streamHandler.stream(request: request)
  
        let receivedEvents = ReceivedEvents()
        let shouldFulfill = ShouldFulfill()

        publisher.sink(receiveCompletion: { _ in }, receiveValue: { value in
            self.syncQueue.sync {
                receivedEvents.append(value)
                shouldFulfill.value(receivedEvents.count == expectedNumberOfResponses)
            }
            if shouldFulfill.value {
                expectation.fulfill()
            }
        }).store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(receivedEvents.count, expectedNumberOfResponses, "Expected \(expectedNumberOfResponses) events")
        XCTAssertEqual(receivedEvents.get(0), StoreReadResponse.loading(origin: .fetcher(name: nil)))
        XCTAssertEqual(receivedEvents.get(1), StoreReadResponse.data(value: expectedData, origin: .fetcher(name: nil) ))
    }
    
    func testStreamFromCachedRequestWithMemoryCacheAndValidData() async throws {
        ttl = Date.distantFuture
        
        let id = "1"
        let request = StoreReadRequest.cached(key: id, refresh: false)
        var cancellables = [AnyCancellable]()

        let expectedNumberOfResponses = 2
        let expectation = expectation(description: "Correct number of responses")

        let expectedData = TestDataModel(id: id, name: id, title: id, ttl: self.ttl)
        
        let memoryCache = CacheBuilder<String, TestDataModel>().build()
        memoryCache.put(value: expectedData, forKey: id)
        
        setUpStreamHandler(memoryCache: memoryCache)
        
        let publisher = streamHandler.stream(request: request)
        
        let receivedEvents = ReceivedEvents()
        let shouldFulfill = ShouldFulfill()
        
        publisher.sink(receiveCompletion: { _ in }, receiveValue: { value in
            self.syncQueue.sync {
                receivedEvents.append(value)
                shouldFulfill.value(receivedEvents.count == expectedNumberOfResponses)
            }
            if shouldFulfill.value {
                expectation.fulfill()
            }
            
        }).store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(receivedEvents.count, expectedNumberOfResponses, "Expected \(expectedNumberOfResponses) events")
        XCTAssertEqual(receivedEvents.get(0), StoreReadResponse.loading(origin: .cache))
        XCTAssertEqual(receivedEvents.get(1), StoreReadResponse.data(value: expectedData, origin: .cache ))
    }

    func testStreamFromCachedRequestWithMemoryCacheAndInvalidData() async throws {
        ttl = Date.distantPast
        
        let id = "1"
        let request = StoreReadRequest.cached(key: id, refresh: false)
        var cancellables = [AnyCancellable]()

        let expectedNumberOfResponses = 4
        let expectation = expectation(description: "Correct number of responses")

        let expectedData = TestDataModel(id: id, name: id, title: id, ttl: self.ttl)
        
        let memoryCache = CacheBuilder<String, TestDataModel>().build()
        memoryCache.put(value: expectedData, forKey: id)
        
        setUpStreamHandler(memoryCache: memoryCache)
        
        let publisher = streamHandler.stream(request: request)
        
        let receivedEvents = ReceivedEvents()
        let shouldFulfill = ShouldFulfill()
        
        publisher.sink(receiveCompletion: { _ in }, receiveValue: { value in
            self.syncQueue.sync {
                receivedEvents.append(value)
                shouldFulfill.value(receivedEvents.count == expectedNumberOfResponses)
            }
            if shouldFulfill.value {
                expectation.fulfill()
            }
            
        }).store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(receivedEvents.count, expectedNumberOfResponses, "Expected \(expectedNumberOfResponses) events")
        XCTAssertEqual(receivedEvents.get(0), StoreReadResponse.loading(origin: .cache))
        XCTAssertEqual(receivedEvents.get(1), StoreReadResponse.error(error: .cache(.validationFailed), origin: .cache))
        XCTAssertEqual(receivedEvents.get(2), StoreReadResponse.loading(origin: .fetcher(name: nil)))
        XCTAssertEqual(receivedEvents.get(3), StoreReadResponse.data(value: expectedData, origin: .fetcher(name: nil)))
    }
    
    func testStreamFromCachedRequestWithMemoryCacheAndNoCachedData() async throws {
        setUpStreamHandler()
        ttl = Date.distantFuture
        
        let id = "1"
        let request = StoreReadRequest.cached(key: id, refresh: false)
        var cancellables = [AnyCancellable]()

        let expectedNumberOfResponses = 4
        let expectation = expectation(description: "Correct number of responses")

        let expectedData = TestDataModel(id: id, name: id, title: id, ttl: self.ttl)

        let publisher = streamHandler.stream(request: request)
        let receivedEvents = ReceivedEvents()
        let shouldFulfill = ShouldFulfill()
        
        publisher.sink(receiveCompletion: { _ in }, receiveValue: { value in
            self.syncQueue.sync {
                receivedEvents.append(value)
                shouldFulfill.value(receivedEvents.count == expectedNumberOfResponses)
            }
            if shouldFulfill.value {
                expectation.fulfill()
            }
        }).store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 1)

        XCTAssertEqual(receivedEvents.count, expectedNumberOfResponses, "Expected \(expectedNumberOfResponses) events")
        XCTAssertEqual(receivedEvents.get(0), StoreReadResponse.loading(origin: .cache))
        XCTAssertEqual(receivedEvents.get(1), StoreReadResponse.loading(origin: .sourceOfTruth))
        XCTAssertEqual(receivedEvents.get(2), StoreReadResponse.loading(origin: .fetcher(name: nil)))
        XCTAssertEqual(receivedEvents.get(3), StoreReadResponse.data(value: expectedData, origin: .fetcher(name: nil) ))
    }
    
    func testStreamFromCachedRefreshRequestWithMemoryCacheAndValidData() async throws {
        ttl = Date.distantFuture
        
        let id = "1"
        let request = StoreReadRequest.cached(key: id, refresh: true)
        var cancellables = [AnyCancellable]()

        let expectedNumberOfResponses = 4
        let expectation = expectation(description: "Correct number of responses")

        let expectedData = TestDataModel(id: id, name: id, title: id, ttl: self.ttl)
        
        let memoryCache = CacheBuilder<String, TestDataModel>().build()
        memoryCache.put(value: expectedData, forKey: id)
        
        setUpStreamHandler(memoryCache: memoryCache)
        
        let publisher = streamHandler.stream(request: request)
        
        let receivedEvents = ReceivedEvents()
        let shouldFulfill = ShouldFulfill()
        
        publisher.sink(receiveCompletion: { _ in }, receiveValue: { value in
            self.syncQueue.sync {
                receivedEvents.append(value)
                shouldFulfill.value(receivedEvents.count == expectedNumberOfResponses)
            }
            if shouldFulfill.value {
                expectation.fulfill()
            }
            
        }).store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(receivedEvents.count, expectedNumberOfResponses, "Expected \(expectedNumberOfResponses) events")
        XCTAssertEqual(receivedEvents.get(0), StoreReadResponse.loading(origin: .cache))
        XCTAssertEqual(receivedEvents.get(1), StoreReadResponse.data(value: expectedData, origin: .cache ))
        XCTAssertEqual(receivedEvents.get(2), StoreReadResponse.loading(origin: .fetcher(name: nil)))
        XCTAssertEqual(receivedEvents.get(3), StoreReadResponse.data(value: expectedData, origin: .fetcher(name: nil) ))
    }
}
