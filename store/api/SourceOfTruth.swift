import Foundation
import Combine

protocol SourceOfTruth {
    associatedtype Key: Hashable
    associatedtype Local
    associatedtype Output
    
    func read(for key: Key) -> AnyPublisher<Output?, StoreError>
    
    func write(key: Key, value: Local) async throws
    
    func delete(key: Key) async throws
    
    func deleteAll() async throws
}
