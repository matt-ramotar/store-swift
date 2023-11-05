import SwiftUI

struct CampaignView: View {
    let campaignId: String
    
    @StateObject var viewModel = CampaignViewModel()

    var body: some View {
        VStack {
            switch viewModel.state {
            case .initial:
                Text("Welcome to the Campaign!").onAppear {viewModel.loadCampaign(id: campaignId)}
            
            case .loading:
                ProgressView("Loading...")

            case .data(let campaign):
                CampaignDetailView(campaign: campaign)

            case .error(let error):
                Text("An error occurred: \(error.localizedDescription)")
            }
        }
    }
}


