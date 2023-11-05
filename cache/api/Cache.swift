import Foundation

protocol Cache {
    associatedtype Key: Hashable
    associatedtype Value
    
    /// Returns the value associated with a key, or `nil` if the key is not present in the cache.
    func getIfPresent(forKey key: Key) -> Value?
    
    /// Returns the value associated with a key, obtaining it from a value producer if necessary.
    /// - Parameter key: The key to look up the value for.
    /// - Parameter valueProducer: A closure that produces a value for the given key.
    /// - Returns: The value associated with the key.
    /// - Throws: An error if the value could not be produced.
    func getOrPut(forKey key: Key, valueProducer: () throws -> Value) throws -> Value
    
    /// Returns a dictionary of the values associated with the keys.
    /// - Parameter keys: An array of keys to look up.
    /// - Returns: A dictionary of key-value pairs for the keys that are present in the cache.
    func getAllPresent(forKeys keys: [Key]) -> [Key: Value]
    
    /// Associates a value with a key in the cache.
    /// - Parameters:
    ///   - key: The key to associate the value with.
    ///   - value: The value to associate with the key.
    func put(value: Value, forKey key: Key)
    
    /// Associates multiple key-value pairs with the cache.
    /// - Parameter keyValuePairs: A dictionary of key-value pairs to associate with the cache.
    func putAll(_ keyValuePairs: [Key: Value])
    
    /// Removes the value associated with a key from the cache.
    /// - Parameter key: The key whose associated value should be removed.
    func invalidate(forKey key: Key)
    
    /// Removes the values associated with the keys from the cache.
    /// - Parameter keys: The keys whose associated values should be removed.
    func invalidateAll(forKeys keys: [Key])
    
    /// Removes all entries from the cache.
    func invalidateAll()
    
    /// Returns the approximate number of entries in the cache.
    func size() -> Int
}

