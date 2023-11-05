import Foundation

internal class FetcherConverterImpl<Network> : FetcherConverter {
    private let _fromDataToNetwork: (Data) -> Network
    init(_ fromDataToNetwork: @escaping (Data) -> Network)  {
        self._fromDataToNetwork = fromDataToNetwork
    }
    
    func fromDataToNetwork(data: Data) -> Network {
        return _fromDataToNetwork(data)
    }
}
