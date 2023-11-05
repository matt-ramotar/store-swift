import Foundation
import CoreData
import Combine

private let ONE_DAY: TimeInterval = 24 * 60 * 60

class CampaignStoreFactory {
    
    func make() -> AnyStore<String, Campaign> {
        let fetcher = FetcherFactory.make({ id in
            let networkData = NetworkCampaign(id: id, name: id, title: id, ttl: Date(timeIntervalSinceNow: ONE_DAY))
            let fetcherResult = FetcherResult.data(value: networkData, fetcherName: nil)
            return Just(fetcherResult).setFailureType(to: StoreError.self).eraseToAnyPublisher()
        })
        
        let converter = ConverterBuilder<NetworkCampaign, CampaignEntity, Campaign>()
            .fromNetworkToOutput({campaign in Campaign(id: campaign.id, name: campaign.name, title: campaign.title, ttl: campaign.ttl) })
            .fromOutputToLocal({campaign in
                self.createCampaignEntity(id: campaign.id, name: campaign.name, title: campaign.title, ttl: campaign.ttl)
            })
            .fromNetworkToLocal({campaign in self.createCampaignEntity(id: campaign.id, name: campaign.name, title: campaign.title, ttl: campaign.ttl)})
            .build()


        let memoryCache = CacheBuilder<String, Campaign>()
            .evictionPolicy(.lru)
            .expirationDuration(ONE_DAY)
            .maxCount(100)
            .build()

        let validator = ValidatorFactory<Campaign>.make({output in
            let now = Date.now
            return output.ttl > now
        })
        
        
     return StoreBuilder<String, NetworkCampaign, CampaignEntity, Campaign>(fetcher: fetcher, converter: converter)
            .memoryCache(memoryCache)
            .validator(validator)
            .build()
    }
    
    private func createCampaignEntity(context: NSManagedObjectContext? = nil, id: String, name: String, title: String, ttl: Date) -> CampaignEntity {
        
        let entity: CampaignEntity
        
        if let context = context {
            entity = CampaignEntity(context: context)
        } else {
            entity = CampaignEntity()
        }

        entity.id = id
        entity.name = name
        entity.title = title
        entity.ttl = ttl
        return entity
    }
}
