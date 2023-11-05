import Foundation

internal class ConverterImpl<Network, Local, Output>: Converter {
    private let fromNetworkToOutputClosure: (Network) -> Output
    private let fromOutputToLocalClosure: (Output) -> Local
    private let fromNetworkToLocalClosure: (Network) -> Local
    
    init(fromNetworkToOutput: @escaping (Network) -> Output, fromOutputToLocal: @escaping (Output) -> Local, fromNetworkToLocal: @escaping (Network) -> Local) {
        self.fromNetworkToOutputClosure = fromNetworkToOutput
        self.fromOutputToLocalClosure = fromOutputToLocal
        self.fromNetworkToLocalClosure = fromNetworkToLocal
    }
    
    func fromNetworkToLocal(_ network: Network) -> Local {
        fromNetworkToLocalClosure(network)
    }
    
    func fromOutputToLocal(_ output: Output) -> Local {
        fromOutputToLocalClosure(output)
    }
    
    func fromNetworkToOutput(_ network: Network) -> Output {
        fromNetworkToOutputClosure(network)
    }
    
    
}
