import CoreData
import Foundation

@objc(RoutineEntity)
public class RoutineEntity: NSManagedObject {
  // MARK: - Properties
  @NSManaged private(set) var name: String
  
  // MARK: - Init
  convenience init(
    context: NSManagedObjectContext,
    name: String
  ) {
    self.init(context: context)
    self.name = name
  }
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<RoutineEntity> {
    NSFetchRequest<RoutineEntity>(entityName: "RoutineEntity")
  }
}
