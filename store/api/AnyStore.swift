import Foundation
import Combine

class AnyStore<Key: Hashable, Output>: Store {
 
    private let _stream: (StoreReadRequest<Key>) -> AnyPublisher<StoreReadResponse<Output>, StoreError>
    private let _clear: (Key) async throws -> Void
    private let _clearAll: () async throws -> Void
    
    init<S: Store>(_ store: S) where S.Key == Key, S.Output == Output {
        self._stream = store.stream
        self._clear = store.clear
        self._clearAll = store.clearAll
    }
    
    func stream(request: StoreReadRequest<Key>) -> AnyPublisher<StoreReadResponse<Output>, StoreError> {
        return _stream(request)
    }
    
    func clear(key: Key) async throws {
        try await _clear(key)
    }
    
    func clearAll() async throws {
        try await _clearAll()
    }
}
