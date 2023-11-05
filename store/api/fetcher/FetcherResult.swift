import Foundation

enum FetcherResult<Network> {
    case data(value: Network, fetcherName: String?)
    case error(error: StoreError)
    init(_ result: Result<Network, StoreError>, name: String?) {
        switch result {
        case .success(let data):
            self = .data(value: data, fetcherName: name)
            
        case .failure(let error):
            self = .error(error: error)
        }
    }
}
