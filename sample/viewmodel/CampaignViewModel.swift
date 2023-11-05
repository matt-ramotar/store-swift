import Foundation
import Combine

enum CampaignState {
    case initial
    case loading
    case data(campaign: Campaign)
    case error(Error)
}

class CampaignViewModel: ObservableObject {
    @Published var state: CampaignState = .initial
    private let store: CampaignStore
    private var cancellables = Set<AnyCancellable>()
    
    init(store: CampaignStore = CampaignStoreFactory().make()) {
        self.store = store
    }
    
    func loadCampaign(id: String) {
        let request = StoreReadRequest.fresh(key: id)
        
        Task {
            do {
                await store.stream(request: request)
                    .sink(receiveCompletion: { [weak self] completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            self?.state = .error(error)
                        }
                    }, receiveValue: { [weak self] response in
                        switch response {
                        case .loading:
                            self?.state = .loading
                        case .data(let value, _):
                            self?.state = .data(campaign: value)
                        case .noNewData:
                            break
                        case let .error(error, _):
                            self?.state = .error(error)
                        case .initial:
                            break
                        }
                    })
                    .store(in: &cancellables)
            }
        }
        
    }
}
