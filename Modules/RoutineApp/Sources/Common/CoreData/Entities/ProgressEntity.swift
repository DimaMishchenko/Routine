import CoreData
import Foundation

@objc(ProgressEntity)
class ProgressEntity: NSManagedObject {
  // MARK: - Properties
  @NSManaged private(set) var current: Int16
  @NSManaged private(set) var goal: Int16
  @NSManaged private(set) var routine: RoutineEntity?
}

extension ProgressEntity {
  // MARK: - Init
  convenience init(
    context: NSManagedObjectContext,
    progress: Progress
  ) {
    self.init(context: context)
    current = Int16(progress.current)
    goal = Int16(progress.goal.rawValue)
  }
  
  func apply(_ progress: Progress) {
    current = Int16(progress.current)
    goal = Int16(progress.goal.rawValue)
  }
}

extension ProgressEntity {
  var model: Progress {
    Progress(
      goal: .init(rawValue: Int(goal)),
      current: Int(current)
    )
  }
}
