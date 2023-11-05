import Foundation
import Combine

internal struct FallbackFetcher<Key: Hashable, Network> : Fetcher {
    var name: String?
    var fallback: AnyFetcher<Key, Network>?
    private let publisherFactory: (Key) -> AnyPublisher<FetcherResult<Network>, StoreError>
    
    init(
        publisherFactory: @escaping (Key) -> AnyPublisher<FetcherResult<Network>, StoreError>,
        name: String,
        fallback: AnyFetcher<Key, Network>?
    ) {
        self.publisherFactory = publisherFactory
        self.name = name
        self.fallback = fallback
    }
    
    func fetch(key: Key) -> AnyPublisher<FetcherResult<Network>, StoreError> {
        return publisherFactory(key)
            .catch { error in
                if let fallback = self.fallback {
                    return fallback.fetch(key: key)
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}
