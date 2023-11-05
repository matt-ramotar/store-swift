//
//  StoreReadResponse.swift
//  store
//
//  Created by mramotar on 11/3/23.
//

import Foundation


enum StoreReadResponse<Output> {
    case initial
    case loading(origin: StoreReadResponseOrigin)
    case data(value: Output, origin: StoreReadResponseOrigin)
    case noNewData(origin: StoreReadResponseOrigin)
    case error(error: StoreError, origin: StoreReadResponseOrigin)
    
    func requireData() throws -> Output {
        switch self {
        case .data(let value, _):
            return value
        case .error(let error, _):
            throw error
        default:
            throw NSError(domain: "StoreReadResponse", code: 0, userInfo: [NSLocalizedDescriptionKey: "There is no data in \(self)"])
        }
    }
    
    func throwIfError() throws {
        if case .error(let error, _) = self {
            throw error
        }
    }
    
    func errorMessageOrNull() -> String? {
        if case .error(let error, _) = self {
            return (error as? LocalizedError)?.errorDescription ?? "Error: \(error)"
        }
        return nil
    }
    
    func dataOrNull() -> Output? {
        if case .data(let value, _) = self {
            return value
        }
        return nil
    }
}


enum StoreReadResponseOrigin {
    case cache
    case sourceOfTruth
    case fetcher(name: String?)
}


extension StoreReadResponseOrigin: Equatable {
    static func == (lhs: StoreReadResponseOrigin, rhs: StoreReadResponseOrigin) -> Bool {
        switch (lhs, rhs) {
        case (.cache, .cache),
             (.sourceOfTruth, .sourceOfTruth):
            return true
        case (.fetcher(let lhsName), .fetcher(let rhsName)):
            return lhsName == rhsName
        default:
            return false
        }
    }
}


extension StoreReadResponse : Equatable where Output: Equatable {
    static func == (lhs: StoreReadResponse, rhs: StoreReadResponse) -> Bool {
            switch (lhs, rhs) {
            case (.loading(let lhsOrigin), .loading(let rhsOrigin)):
                return lhsOrigin == rhsOrigin
            case (.data(let lhsValue, let lhsOrigin), .data(let rhsValue, let rhsOrigin)):
                return lhsValue == rhsValue && lhsOrigin == rhsOrigin
            case (.error(let lhsError, let lhsOrigin), .error(let rhsError, let rhsOrigin)):
                return lhsError == rhsError && lhsOrigin == rhsOrigin
            default:
                return false
            }
        }
}


extension StoreReadResponse where Output == Any {
    func swapType<T>() -> StoreReadResponse<T> {
        switch self {
        case .loading(let origin):
            return .loading(origin: origin)
        case .noNewData(let origin):
            return .noNewData(origin: origin)
        case let .error(error, origin):
            return .error(error: error, origin: origin)
        case .initial:
            return .initial
        case .data:
            fatalError("Cannot swap type for StoreReadResponse.data")
            }
    }
}
