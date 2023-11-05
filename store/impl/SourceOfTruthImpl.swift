import Foundation
import Combine

internal class SourceOfTruthImpl<Key: Hashable, Local, Output> : SourceOfTruth {

    typealias Key = Key
    typealias Local = Local
    typealias Output = Output
    
    private let readImpl: (Key) -> AnyPublisher<Output?, StoreError>
    private let writeImpl: (Key, Local) async throws -> Void
    private let deleteImpl: ((Key) async throws -> Void)?
    private let deleteAllImpl: (() async throws -> Void)?
    
    init(
        readImpl : @escaping (Key) -> AnyPublisher<Output?, StoreError>,
        writeImpl: @escaping (Key, Local) async throws -> Void,
        deleteImpl: ((Key) async throws -> Void)? = nil,
        deleteAllImpl: (() async throws -> Void)? = nil
    ) {
        self.readImpl = readImpl
        self.writeImpl = writeImpl
        self.deleteImpl = deleteImpl
        self.deleteAllImpl = deleteAllImpl
    }
    
    func read(for key: Key) -> AnyPublisher<Output?, StoreError> {
        return readImpl(key)
    }
    
    func write(key: Key, value: Local) async throws {
        return try await writeImpl(key, value)
    }
    
    func delete(key: Key) async throws {
        try await  deleteImpl?(key)
    }
    
    func deleteAll() async throws {
        try await deleteAllImpl?()
    }
    
    
}
