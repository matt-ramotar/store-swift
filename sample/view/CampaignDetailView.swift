import SwiftUI

struct CampaignDetailView: View {
    let campaign: Campaign

    var body: some View {
        VStack {
            Text(campaign.title)
                .font(.title)
        }
    }
}
