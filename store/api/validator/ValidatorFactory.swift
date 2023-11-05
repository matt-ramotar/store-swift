import Foundation

struct ValidatorFactory<Output> {
    static func make(_ validate: @escaping (Output) -> Bool) -> AnyValidator<Output> {
        let validatorImpl = ValidatorImpl(validate)
        return AnyValidator(validatorImpl)
    }
}
