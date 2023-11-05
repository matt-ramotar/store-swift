import Foundation

class AnyValidator<Output> : Validator {
    private let _isValid: (Output) async -> Bool
    
    init<V: Validator>(_ validator: V) where V.Output == Output {
        self._isValid = validator.isValid
    }
    
    func isValid(_ item: Output) async -> Bool {
        return await _isValid(item)
    }
}
