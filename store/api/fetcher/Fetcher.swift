import Combine
import Foundation


protocol Fetcher {
    associatedtype Key: Hashable
    associatedtype Network
    
    var name: String? {get}
    var fallback: AnyFetcher<Key, Network>? {get}
    
    func fetch(key: Key) -> AnyPublisher<FetcherResult<Network>, StoreError>
}
