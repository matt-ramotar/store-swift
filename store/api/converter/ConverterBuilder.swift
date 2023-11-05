import Foundation

class ConverterBuilder<Network, Local, Output> {
    private var fromOutputToLocalClosure: ((Output) -> Local)?
    private var fromNetworkToLocalClosure: ((Network) -> Local)?
    private var fromNetworkToOutputClosure: ((Network) -> Output)?
    
    @discardableResult
    func fromOutputToLocal(_ converter: @escaping (Output) -> Local) -> Self {
        self.fromOutputToLocalClosure = converter
        return self
    }
    
    @discardableResult
    func fromNetworkToLocal(_ converter: @escaping (Network) -> Local) -> Self {
        self.fromNetworkToLocalClosure = converter
        return self
    }
    
    
    @discardableResult
    func fromNetworkToOutput(_ converter: @escaping (Network) -> Output) -> Self {
        self.fromNetworkToOutputClosure = converter
        return self
    }
    
    func build() -> AnyConverter<Network, Local, Output> {
        guard let fromOutputToLocal = fromOutputToLocalClosure,
              let fromNetworkToLocal = fromNetworkToLocalClosure,
              let fromNetworkToOutput = fromNetworkToOutputClosure else {
            fatalError("You must provide fromNetworkToOutput, fromOutputToLocal, and fromNetworkToLocal closures before building the converter.")
        }
        
        let impl = ConverterImpl(fromNetworkToOutput: fromNetworkToOutput, fromOutputToLocal: fromOutputToLocal, fromNetworkToLocal: fromNetworkToLocal)
        return AnyConverter(impl)
    }
}
