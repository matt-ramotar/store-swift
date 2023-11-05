import Foundation


enum FetcherError : Error {
    case invalidUrl
    case conversionFailed
    case networkError(Error)
    case nilSelf
}

enum CacheError: Error {
    case conversionFailed
    case validationFailed
    case nilSelf
}

enum SourceOfTruthError: Error {
    case conversionFailed
    case validationFailed
    case nilSelf
}

enum StoreError: Error {
    case fetcher(FetcherError)
    case cache(CacheError)
    case sourceOfTruth(SourceOfTruthError)
}

extension StoreError: Equatable {
    static func == (lhs: StoreError, rhs: StoreError) -> Bool {
        switch (lhs, rhs) {
        case (.fetcher(let lhsError), .fetcher(let rhsError)):
            switch (lhsError, rhsError) {
            case (.invalidUrl, .invalidUrl),
                (.conversionFailed, .conversionFailed),
                (.nilSelf, .nilSelf):
                return true
            default:
                return false
            }
            
        case (.cache(let lhsError), .cache(let rhsError)):
            switch (lhsError, rhsError) {
            case (.validationFailed, .validationFailed),
                (.conversionFailed, .conversionFailed),
                (.nilSelf, .nilSelf):
                return true
            default:
                return false
            }
            
        case (.sourceOfTruth(let lhsError), .sourceOfTruth(let rhsError)):
            switch (lhsError, rhsError) {
            case (.validationFailed, .validationFailed),
                (.conversionFailed, .conversionFailed),
                (.nilSelf, .nilSelf):
                return true
            default:
                return false
            }
            
        default:
            return false
        }
    }
}
