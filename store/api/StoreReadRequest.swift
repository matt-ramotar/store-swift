//
//  StoreReadRequest.swift
//  store
//
//  Created by mramotar on 10/28/23.
//

import Foundation

struct StoreReadRequest<Key: Hashable> {
    let key: Key
    let skipCaches: Bool
    let refresh: Bool
    let fallBackToSourceOfTruth: Bool
    
    init(
        key: Key,
        skipCaches: Bool = false,
        refresh: Bool = false,
        fallBackToSourceOfTruth: Bool = false
    ) {
        self.key = key
        self.skipCaches = skipCaches
        self.refresh = refresh
        self.fallBackToSourceOfTruth = fallBackToSourceOfTruth
    }
}

extension StoreReadRequest {
    static func fresh(key: Key, fallBackToSourceOfTruth: Bool = false) -> StoreReadRequest {
        return StoreReadRequest(key: key, skipCaches: true, refresh: true, fallBackToSourceOfTruth: fallBackToSourceOfTruth)
    }
    
    static func cached(key: Key, refresh: Bool) -> StoreReadRequest {
        return StoreReadRequest(key: key, skipCaches: false, refresh: refresh)
    }
}
