import Foundation

internal struct ValidatorImpl<Output>: Validator {
    private let validator: (Output) async -> Bool
    init(_ validator: @escaping (Output) async -> Bool) {
        self.validator = validator
    }
    func isValid(_ item: Output) async -> Bool {
        return await validator(item)
    }
}
