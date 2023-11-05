import Combine
import Foundation


protocol FetcherConverter {
    associatedtype Network
    func fromDataToNetwork(data: Data) -> Network
}

class AnyFetcherConverter<Network> : FetcherConverter {
    private let _fromDataToNetwork: (Data) -> Network
    init<F: FetcherConverter>(_ converter: F) where F.Network == Network {
        self._fromDataToNetwork = converter.fromDataToNetwork
    }
    
    func fromDataToNetwork(data: Data) -> Network {
        return _fromDataToNetwork(data)
    }
}

struct FetcherConverterFactory<Network> {
    static func make(_ fromDataToNetwork: @escaping (Data) -> Network ) -> AnyFetcherConverter<Network> {
        let fetcherConverter =  FetcherConverterImpl<Network>(fromDataToNetwork)
        return AnyFetcherConverter(fetcherConverter)
    }
}
