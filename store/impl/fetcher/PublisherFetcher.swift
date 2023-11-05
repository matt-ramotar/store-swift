import Foundation
import Combine

internal struct PublisherFetcher<Key: Hashable, Network> : Fetcher {

    var name: String?
    var fallback: AnyFetcher<Key, Network>?
    private let publisherFactory: (Key) -> AnyPublisher<FetcherResult<Network>, StoreError>
    
    init(
        publisherFactory: @escaping (Key) -> AnyPublisher<FetcherResult<Network>, StoreError>,
        name: String?,
        fallback: AnyFetcher<Key, Network>?
    ) {
        self.publisherFactory = publisherFactory
        self.name = name
        self.fallback = fallback
    }
    
    func fetch(key: Key) -> AnyPublisher<FetcherResult<Network>, StoreError> {
        return publisherFactory(key)
            .eraseToAnyPublisher()
    }
}
