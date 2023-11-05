import Foundation
import Combine

internal protocol StreamHandler {
    associatedtype Key: Hashable
    associatedtype Output
    
    func stream(request: StoreReadRequest<Key>) -> AnyPublisher<StoreReadResponse<Output>, StoreError>
}
