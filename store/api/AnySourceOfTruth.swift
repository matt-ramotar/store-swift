import Foundation
import Combine

class AnySourceOfTruth<Key: Hashable, Local, Output> : SourceOfTruth {
    private let _read: (Key) -> AnyPublisher<Output?, StoreError>
    private let _write: (Key, Local) async throws -> Void
    private let _delete: ((Key) async throws -> Void)?
    private let _deleteAll: (() async throws -> Void)?
    
    init<S: SourceOfTruth>(_ sourceOfTruth: S) where S.Key == Key, S.Local == Local, S.Output == Output {
        self._read = sourceOfTruth.read
        self._write = sourceOfTruth.write
        self._delete = sourceOfTruth.delete
        self._deleteAll = sourceOfTruth.deleteAll
    }
    
    func read(for key: Key) -> AnyPublisher<Output?, StoreError> {
        return _read(key)
    }
    
    func write(key: Key, value: Local) async throws {
        return try await _write(key, value)
    }
    
    func delete(key: Key) async throws {
        try await _delete?(key)
    }
    
    func deleteAll() async throws {
        try await _deleteAll?()
    }
}

