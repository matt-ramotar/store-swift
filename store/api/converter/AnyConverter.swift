import Foundation

class AnyConverter<Network, Local, Output> : Converter {
    private let _fromNetworkToOutput: (Network) -> Output
    private let _fromOutputToLocal: (Output) -> Local
    private let _fromNetworkToLocal: (Network) -> Local
    
    
    init<C: Converter>(_ converter: C) where C.Network == Network, C.Local == Local, C.Output == Output {
        self._fromNetworkToOutput = converter.fromNetworkToOutput
        self._fromNetworkToLocal = converter.fromNetworkToLocal
        self._fromOutputToLocal = converter.fromOutputToLocal
    }
    
    func fromNetworkToLocal(_ network: Network) -> Local {
        return _fromNetworkToLocal(network)
    }
    func fromOutputToLocal(_ output: Output) -> Local {
        return _fromOutputToLocal(output)
    }
    func fromNetworkToOutput(_ network: Network) -> Output {
        return _fromNetworkToOutput(network)
    }
}
