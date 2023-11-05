# StoreImpl

`StoreImpl` is an internal class that implements the `Store` protocol, acting as a simplified interface for data access within your application. It encapsulates the underlying streaming, caching, and data storage logic, providing a straightforward API to fetch, stream, and manage data.

## Features:

1. **Streaming Data**: Stream data based on a given `StoreReadRequest`.
2. **Clearing Cache**: Ability to clear cached data for a specified key or clear all cached data.
3. **Delegated Handling**: Delegates the stream handling and data management to a `streamHandler` and a `sourceOfTruth` respectively.

## Usage:

```swift
let streamHandler: AnyStreamHandler<KeyType, OutputType> = // ...
let sourceOfTruth: AnySourceOfTruth<KeyType, LocalType, OutputType>? = // ...
let memoryCache: AnyCache<KeyType, OutputType>? = // ...

let store = StoreImpl(
    streamHandler: streamHandler,
    sourceOfTruth: sourceOfTruth,
    memoryCache: memoryCache
)

let request = StoreReadRequest<KeyType>.cached(key: someKey, refresh: false)
let publisher = store.stream(request: request)

publisher.sink(receiveCompletion: { completion in
    // Handle completion
}, receiveValue: { value in
    // Handle value
}).store(in: &cancellables)
```

## Method Overview:

- `init(streamHandler:sourceOfTruth:memoryCache:)`: Initializes a new `StoreImpl` instance with a specified `streamHandler`, an optional `sourceOfTruth`, and an optional `memoryCache`.

- `stream(request:)`: Provides a publisher for streaming data based on the specified `StoreReadRequest`. This method delegates the stream handling to the `streamHandler`.

- `clear(key:)`: Clears the cached data for the specified key both from the `memoryCache` and the `sourceOfTruth`.

- `clearAll()`: Clears all cached data from both the `memoryCache` and the `sourceOfTruth`.

## Dependencies:

- `AnyStreamHandler`: An abstraction for handling data streams. This is where the main data handling logic resides.
- `AnySourceOfTruth`: An optional abstraction for a source of truth to read from or write to. This is used for clearing data.
- `AnyCache`: An optional abstraction for caching data in memory. This is also used for clearing data.

This `StoreImpl` class is designed to be a part of a larger data management system where it acts as a facade for simplified data access and management. By providing a clear and simple API, it helps in isolating the complexities of data streaming and storage, making it easier to work with data in a controlled and managed way.
