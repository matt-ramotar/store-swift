import Foundation

class CacheBuilder<Key: Hashable, Value> {
    private var maxCount: Int = 1000
    private var evictionPolicy: EvictionPolicy = .lru
    private var expirationDuration: TimeInterval? = nil
    
    func maxCount(_ count: Int) -> CacheBuilder {
        self.maxCount = count
        return self
    }
    
    func evictionPolicy(_ policy: EvictionPolicy) -> CacheBuilder {
        self.evictionPolicy = policy
        return self
    }
    
    func expirationDuration(_ duration: TimeInterval) -> CacheBuilder {
        self.expirationDuration = duration
        return self
    }
    

    func build() -> AnyCache<Key, Value> {
        let cacheImpl = CacheImpl<Key, Value>(
            maxCount: maxCount,
            evictionPolicy: evictionPolicy,
            expirationDuration: expirationDuration
        )
        return AnyCache(cacheImpl)
    }
}
