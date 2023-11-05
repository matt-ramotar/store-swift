import Combine
import Foundation

internal class HashablePublishers<D, E: Error>: Hashable {
    private let label: String
    private let lock: DispatchQueue
    
    private var publishers: [AnyPublisher<D, E>] = []
    
    init(label: String) {
        self.label = label
        self.lock = DispatchQueue(label: label)
    }
    
    func append(_ publisher: AnyPublisher<D, E>) {
        lock.sync {
            publishers.append(publisher)
        }
    }

    func get() -> [AnyPublisher<D, E>] {
        return lock.sync { publishers }
    }
    
    static func == (lhs: HashablePublishers<D, E>, rhs: HashablePublishers<D, E>) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
