import Foundation

class CacheImpl<Key: Hashable, Value> : Cache {
    private var count: Int = 0
    private let lock = NSLock()
    
     private var maxCount: Int
     private var evictionPolicy: EvictionPolicy
     private var expirationDuration: TimeInterval?
     private var creationTimestamps = [Key: Date]()
    private var targetCount: Int
    
    private class WrappedKey: NSObject {
            let key: Key
            
            init(_ key: Key) {
                self.key = key
            }
            
            override func isEqual(_ object: Any?) -> Bool {
                guard let other = object as? WrappedKey else { return false }
                return other.key == key
            }
            
            override var hash: Int {
                return key.hashValue
            }
        }
      
    private class Entry {
           let value: Value
           let creationDate: Date
           
           init(value: Value) {
               self.value = value
               self.creationDate = Date()
           }
       }
      
      private let nsCache = NSCache<WrappedKey, Entry>()
    private var lastAccessTimes = [Key: Date]()

    
    init(
           maxCount: Int,
           evictionPolicy: EvictionPolicy,
           expirationDuration: TimeInterval?
       ) {
           self.maxCount = maxCount
           self.evictionPolicy = evictionPolicy
           self.expirationDuration = expirationDuration
           nsCache.countLimit = maxCount
           self.targetCount = maxCount * (9/10)
       }
    
    func getIfPresent(forKey key: Key) -> Value? {
        defer { lastAccessTimes[key] = Date() }

        guard let entry = nsCache.object(forKey: WrappedKey(key)) else {
            return nil
        }
        
        if let expirationDuration = expirationDuration,
           Date().timeIntervalSince(entry.creationDate) > expirationDuration {
            // Entry has expired, so remove it from the cache
            invalidate(forKey: key)
            return nil
        }
        
        return entry.value
    }
        
        func getOrPut(forKey key: Key, valueProducer: () throws -> Value) throws -> Value {
            if let value = getIfPresent(forKey: key) {
                return value
            } else {
                let newValue = try valueProducer()
                put(value: newValue, forKey: key)
                return newValue
            }
        }
        
        func getAllPresent(forKeys keys: [Key]) -> [Key: Value] {
            var result = [Key: Value]()
            for key in keys {
                if let value = getIfPresent(forKey: key){
                    result[key] = value
                }
            }
            return result
        }
        
    func put(value: Value, forKey key: Key) {
        defer { lastAccessTimes[key] = Date() }
        
        if count >= maxCount {
            performEviction()
        }

        let wrappedKey = WrappedKey(key)
        lock.lock()
        defer { lock.unlock() }
        if nsCache.object(forKey: wrappedKey) == nil {
            count += 1
        }
        nsCache.setObject(Entry(value: value), forKey: wrappedKey)
        creationTimestamps[key] = Date()
    }
    
    
    func putAll(_ keyValuePairs: [Key: Value]) {

        lock.lock()
        defer { lock.unlock() }
        for (key, value) in keyValuePairs {
            put(value: value, forKey: key)
        }
    }
    
    func invalidate(forKey key: Key) {
        let wrappedKey = WrappedKey(key)
        lock.lock()
        defer { lock.unlock() }
        if nsCache.object(forKey: wrappedKey) != nil {
            count -= 1
        }
        nsCache.removeObject(forKey: wrappedKey)
    }
    
    func invalidateAll(forKeys keys: [Key]) {
        lock.lock()
        defer { lock.unlock() }
        for key in keys {
            invalidate(forKey: key)
        }
    }
    
    func invalidateAll() {
        lock.lock()
        defer { lock.unlock() }
        count = 0
        nsCache.removeAllObjects()
    }
    
    func size() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return count
    }
    
    func performEviction() {
        
        switch evictionPolicy {
        case .lru:
            performLRUEviction()
        }
    }
    
    func performLRUEviction(){
        guard count > targetCount else { return }
        
        let sortedKeys = lastAccessTimes.keys.sorted { lastAccessTimes[$0]! > lastAccessTimes[$1]! }
        for key in sortedKeys.dropFirst(targetCount) {
            invalidate(forKey: key)
        }
    }
}
