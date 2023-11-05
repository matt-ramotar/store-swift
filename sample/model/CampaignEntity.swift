import Foundation
import CoreData

class CampaignEntity : NSManagedObject {
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var title: String
    @NSManaged var ttl: Date
}
