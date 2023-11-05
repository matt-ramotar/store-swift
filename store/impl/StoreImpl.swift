import Combine
import Foundation


/// `StoreImpl` is an internal class conforming to the `Store` protocol.
/// It provides a simplified interface for data access within applications.
/// It encapsulates the underlying streaming, caching, and data storage logic, offering a straightforward API to fetch, stream, and manage data.
internal class StoreImpl<Key: Hashable, Output, Local>: Store {
    
    /// An instance conforming to `AnyStreamHandler` protocol responsible for handling data streams.
    private let streamHandler: AnyStreamHandler<Key, Output>
    
    /// An optional instance conforming to `AnySourceOfTruth` protocol representing the source of truth for data.
    /// It's used for reading from or writing to a persistent storage.
    private let sourceOfTruth: AnySourceOfTruth<Key, Local, Output>?
    
    /// An optional instance conforming to `AnyCache` protocol for caching data in memory.
    private let memoryCache: AnyCache<Key, Output>?
    
    init(
        streamHandler: AnyStreamHandler<Key, Output>,
        sourceOfTruth: AnySourceOfTruth<Key, Local, Output>? = nil,
        memoryCache: AnyCache<Key, Output>? = nil
    ) {
        self.streamHandler = streamHandler
        self.sourceOfTruth = sourceOfTruth
        self.memoryCache = memoryCache
    }

    
    /// Provides a publisher for streaming data based on the specified `StoreReadRequest`.
    /// This method delegates the stream handling to the `streamHandler`.
    /// - Parameter request: A `StoreReadRequest` object specifying the data request.
    /// - Returns: A publisher for `StoreReadResponse` of generic type `Output`.
    func stream(request: StoreReadRequest<Key>) -> AnyPublisher<StoreReadResponse<Output>, StoreError> {
        return streamHandler.stream(request: request)
    }
    
    /// Clears the cached data for the specified key both from the `memoryCache` and the `sourceOfTruth`.
    /// - Parameter key: The key identifying the data to be cleared.
    /// - Throws: An error if there's a failure in deleting data from the `sourceOfTruth`.
    func clear(key: Key) async throws {
        memoryCache?.invalidate(forKey: key)
        try await sourceOfTruth?.delete(key: key)
    }
    
    /// Clears all cached data from both the `memoryCache` and the `sourceOfTruth`.
    /// - Throws: An error if there's a failure in deleting data from the `sourceOfTruth`.
    func clearAll() async throws {
        memoryCache?.invalidateAll()
        try await sourceOfTruth?.deleteAll()
    }
}

