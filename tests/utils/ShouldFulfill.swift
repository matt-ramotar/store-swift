import Foundation

class ShouldFulfill {
    private(set) var _shouldFulfill: Bool = false
    private let lock = NSLock()

    func value(_ shouldFulfill: Bool) {
        lock.lock()
        defer { lock.unlock() }
        _shouldFulfill = shouldFulfill
    }

    var value: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _shouldFulfill
    }
}
