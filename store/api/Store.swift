import Foundation
import Combine

/// `Store` is a protocol defining the core functionalities of a data store within an application.
/// It provides a set of methods for streaming data, as well as clearing cached data either by a specific key or entirely.
/// Conforming types are expected to provide implementations for data streaming and cache management based on the application's requirements.
protocol Store {
    
    /// The type representing the key used to identify and access data.
    associatedtype Key: Hashable
    
    /// The type representing the data output.
    associatedtype Output

    /// Provides a publisher for streaming data based on the specified `StoreReadRequest`.
    /// This method should handle data retrieval logic, including caching, network fetching, and reading from a persistent source of truth.
    /// - Parameter request: A `StoreReadRequest` object specifying the data request.
    /// - Returns: A publisher for `StoreReadResponse` of generic type `Output`.
    func stream(request: StoreReadRequest<Key>) -> AnyPublisher<StoreReadResponse<Output>, StoreError>

    /// Clears the cached data for the specified key.
    /// Implementing types should handle clearing data from memory caches, and/or a persistent source of truth as appropriate.
    /// - Parameter key: The key identifying the data to be cleared.
    /// - Throws: An error if there's a failure in deleting data.
    func clear(key: Key) async throws

    /// Clears all cached data.
    /// Implementing types should handle clearing all data from memory caches, and/or a persistent source of truth as appropriate.
    /// - Throws: An error if there's a failure in deleting data.
    func clearAll() async throws
}
