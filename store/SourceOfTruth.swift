//
//  SourceOfTruth.swift
//  store
//
//  Created by mramotar on 10/27/23.
//






struct SourceOfTruthWriteException: Error, Equatable {
    let key: Any?
    let value: Any?
    let cause: Error
    
    static func == (lhs: SourceOfTruthWriteException, rhs: SourceOfTruthWriteException) -> Bool {
        lhs.key as? NSObject == rhs.key as? NSObject &&
        lhs.value as? NSObject == rhs.value as? NSObject &&
        (lhs.cause as NSError).isEqual(rhs.cause as NSError)
    }
}


struct SourceOfTruthReadException : Error, Equatable {
    let key: Any?
    let cause: Error
    
    static func == (lhs: SourceOfTruthReadException, rhs: SourceOfTruthReadException) -> Bool {
        lhs.key as? NSObject == rhs.key as? NSObject &&
        (lhs.cause as NSError).isEqual(rhs.cause as NSError)
    }
}







