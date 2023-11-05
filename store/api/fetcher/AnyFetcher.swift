import Foundation
import Combine

class AnyFetcher<Key: Hashable, Network>: Fetcher {
    private let _fetch: (Key) -> AnyPublisher<FetcherResult<Network>, StoreError>
    init<F: Fetcher>(_ fetcher: F) where F.Key == Key, F.Network == Network {
        self.name = fetcher.name
        self.fallback = fetcher.fallback
        self._fetch = fetcher.fetch
    }
    
    var name: String?
    var fallback: AnyFetcher<Key, Network>?
    func fetch(key: Key) -> AnyPublisher<FetcherResult<Network>, StoreError> {
        return _fetch(key)
    }
}
