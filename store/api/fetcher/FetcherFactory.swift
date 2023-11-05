import Foundation
import Combine

struct FetcherFactory {
    
    static func make<Key: Hashable, Network>(
        _ fetch: @escaping (Key) -> AnyPublisher<FetcherResult<Network>, StoreError>
    ) -> AnyFetcher<Key, Network> {
        let fetcher = PublisherFetcher<Key, Network>(publisherFactory: fetch, name: nil, fallback: nil)
        return AnyFetcher(fetcher)
    }
    
    static func makeWithFallback<Key: Hashable, Network>(
        name: String,
        fetch: @escaping (Key) -> AnyPublisher<FetcherResult<Network>, StoreError>,
        fallback: AnyFetcher<Key, Network>
    ) -> AnyFetcher<Key, Network> {
        let fetcher = FallbackFetcher<Key, Network>(publisherFactory: fetch, name: name, fallback: fallback)
        return AnyFetcher(fetcher)
    }
    
    static func makeFromPublisher<Key: Hashable, Network>(
        _ publisherFactory: @escaping (Key) -> AnyPublisher<FetcherResult<Network>, StoreError>,
        name: String?,
        fallback: AnyFetcher<Key, Network>?
    ) -> AnyFetcher<Key, Network> {
        let fetcher = PublisherFetcher(publisherFactory: publisherFactory, name: name, fallback: fallback)
            return AnyFetcher(fetcher)
        }
    
    
}
