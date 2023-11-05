import Foundation

protocol Validator {
    associatedtype Output
    
    /**
     Determines whether a `Store` item is valid.
     If invalid, `Store` will get the latest network valid using `Fetcher`.
     `Store` will not validate network responses.
     */
    func isValid(_ item: Output) async -> Bool
}
