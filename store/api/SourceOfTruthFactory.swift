import Foundation
import Combine

struct SourceOfTruthFactory<Key: Hashable, Local, Output> {
    
    static func make(
        read: @escaping (Key) -> AnyPublisher<Output?, StoreError>,
        write: @escaping (Key, Local) async throws -> Void,
        delete: ((Key) async throws -> Void)? = nil,
        deleteAll: (() async throws -> Void)? = nil
    ) -> AnySourceOfTruth<Key, Local, Output> {
        
        let sourceOfTruthImpl = SourceOfTruthImpl(
            readImpl: read,
            writeImpl: write,
            deleteImpl: delete,
            deleteAllImpl: deleteAll
        )
        
        return AnySourceOfTruth(sourceOfTruthImpl)
    }
}

