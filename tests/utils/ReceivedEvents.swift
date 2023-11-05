import Foundation

class ReceivedEvents {
    private(set) var events: [StoreReadResponse<TestDataModel>] = []
    private let lock = NSLock()

    func append(_ event: StoreReadResponse<TestDataModel>) {
        lock.lock()
        defer { lock.unlock() }
        events.append(event)
    }

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return events.count
    }
    
    func get(_ index: Int) -> StoreReadResponse<TestDataModel>? {
        guard index < events.count else {
            return nil
        }
        return events[index]
    }
}
