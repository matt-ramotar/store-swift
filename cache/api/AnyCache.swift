import Foundation

class AnyCache<Key: Hashable, Value>: Cache {
    private let _getIfPresent: (Key) -> Value?
    private let _getOrPut: (Key, () throws -> Value) throws -> Value
    private let _getAllPresent: ([Key]) -> [Key: Value]
    private let _put: (Value, Key) -> Void
    private let _putAll: ([Key: Value]) -> Void
    private let _invalidate: (Key) -> Void
    private let _invalidateAllKeys: ([Key]) -> Void
    private let _invalidateAll: () -> Void
    private let _size: () -> Int
    
    init<C: Cache>(_ cache: C) where C.Key == Key, C.Value == Value {
        self._getIfPresent = cache.getIfPresent
        self._getOrPut = cache.getOrPut
        self._getAllPresent = cache.getAllPresent
        self._put = cache.put
        self._putAll = cache.putAll
        self._invalidate = cache.invalidate
        self._invalidateAllKeys = cache.invalidateAll
        self._invalidateAll = cache.invalidateAll
        self._size = cache.size
    }
    
    func getIfPresent(forKey key: Key) -> Value? {
        return _getIfPresent(key)
    }
    
    func getOrPut(forKey key: Key, valueProducer: () throws -> Value) throws -> Value {
        return try _getOrPut(key, valueProducer)
    }
    
    func getAllPresent(forKeys keys: [Key]) -> [Key: Value] {
        return _getAllPresent(keys)
    }
    
    func put(value: Value, forKey key: Key) {
        _put(value, key)
    }
    
    func putAll(_ keyValuePairs: [Key: Value]) {
        _putAll(keyValuePairs)
    }
    
    func invalidate(forKey key: Key) {
        _invalidate(key)
    }
    
    func invalidateAll(forKeys keys: [Key]) {
        _invalidateAllKeys(keys)
    }
    
    func invalidateAll() {
        _invalidateAll()
    }
    
    func size() -> Int {
        return _size()
    }
}
