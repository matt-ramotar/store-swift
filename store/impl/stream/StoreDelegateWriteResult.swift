import Foundation

internal enum StoreDelegateWriteResult {
    case success
    case error(StoreDelegateWriteError)
}

internal enum StoreDelegateWriteError: Error {
    case message(String)
    case exception(Error)
}
