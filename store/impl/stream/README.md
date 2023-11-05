# StreamHandlerImpl

`StreamHandlerImpl` is a class responsible for managing and coordinating data streams from different data sources including a network fetcher, a source of truth, and an optional memory cache. It acts as an orchestrator that decides from where to fetch data, how to cache it, and how to serve it based on the given `StoreReadRequest`. The class is generic and can handle any type of data as long as the keys, network data, local data, and output data types are specified.

## Features:

1. **Fetching from Network:** It can fetch data from a network source using a provided fetcher.
2. **Converting Data:** Converts network data to local and output data using a provided converter.
3. **Validating Data:** Optionally validates the data using a provided validator.
4. **Reading/Writing to a Source of Truth:** It can read from or write to a source of truth.
5. **Caching Data:** Optionally caches data in a memory cache.
6. **Managing Concurrent Access:** It manages concurrent access using locks to ensure thread-safety.
7. **Tracking Subscriptions:** It keeps track of active subscriptions and cancellables to ensure proper lifecycle management.

## Usage:

```swift
let fetcher: AnyFetcher<KeyType, NetworkType> = // ...
let converter: AnyConverter<NetworkType, LocalType, OutputType> = // ...
let sourceOfTruth: AnySourceOfTruth<KeyType, LocalType, OutputType>? = // ...
let validator: AnyValidator<OutputType>? = // ...
let memoryCache: AnyCache<KeyType, OutputType>? = // ...

let streamHandler = StreamHandlerImpl(
    fetcher: fetcher,
    converter: converter,
    sourceOfTruth: sourceOfTruth,
    validator: validator,
    memoryCache: memoryCache
)

let request = StoreReadRequest<KeyType>.cached(key: someKey, refresh: false)
let publisher = streamHandler.stream(request: request)

publisher.sink(receiveCompletion: { completion in
    // Handle completion
}, receiveValue: { value in
    // Handle value
}).store(in: &cancellables)
```

## Method Overview:

- `stream(request:)`: This method is the entry point for requesting a data stream. It prepares the necessary resources for the request, offloads the request handling to a background task, and immediately returns a publisher for the provided key.
- `setUpForRequest(_:)`: Sets up necessary resources like locks, cancellables, and subjects for the provided request.
- `offloadHandlingRequest(_:)`: Offloads the handling of the request to a background task to ensure the publisher is returned immediately.
- `handleRequest(_:)`: Handles the request based on the specified parameters in the `StoreReadRequest`.
- `getFromMemoryCache(key:)`: Attempts to get data from the memory cache.
- `handleSkipCaches(request:)`: Handles a request that wants to skip caches and fetch from the network directly.
- `handleCachedData(request:cachedData:)`: Handles data found in the cache.
- `handleSourceOfTruthOrNetworkFetch(request:)`: Handles fetching from the source of truth or the network.
- `handleOutputDataValidation(request:outputData:origin:)`: Validates the fetched data, if a validator is provided.
- `fetchFromNetworkAndWriteToSourceOfTruth(key:fallBackToSourceOfTruth:)`: Fetches data from the network, writes it to the source of truth, and updates the memory cache.
- `write(key:value:)`: Writes data to the source of truth and updates the memory cache.
- `tryFallBackToSourceOfTruth(key:error:)`: Tries to fall back to the source of truth on a network fetch error.
- `send(_:)`: Sends a response to the subject for the specified key.
- `eraseToAnyPublisher(_:)`: Erases the type of the subject and returns it as an `AnyPublisher`.

## Dependencies:

- `AnyFetcher`: An abstraction for fetching data from the network.
- `AnyConverter`: An abstraction for converting data between network, local, and output representations.
- `AnySourceOfTruth`: An optional abstraction for a source of truth to read from or write to.
- `AnyValidator`: An optional abstraction for validating data.
- `AnyCache`: An optional abstraction for caching data in memory.
