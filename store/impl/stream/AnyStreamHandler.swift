import Foundation
import Combine

internal class AnyStreamHandler<Key: Hashable, Output> : StreamHandler {
    private let _stream: (StoreReadRequest<Key>) -> AnyPublisher<StoreReadResponse<Output>, StoreError>
    
    init<S: StreamHandler>(_ streamHandler: S) where S.Key == Key, S.Output == Output {
        self._stream = streamHandler.stream
    }
    
    
    func stream(request: StoreReadRequest<Key>) -> AnyPublisher<StoreReadResponse<Output>, StoreError> {
        return _stream(request)
    }
}
