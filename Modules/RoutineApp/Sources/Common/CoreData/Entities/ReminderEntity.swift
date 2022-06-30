import CoreData
import Foundation

@objc(ReminderEntity)
class ReminderEntity: NSManagedObject {
  // MARK: - Properties
  @NSManaged private(set) var uuid: UUID
  @NSManaged private(set) var contentJson: Data
  @NSManaged private(set) var routine: RoutineEntity?
  
  var type: ReminderType {
    get {
      guard let type = try? JSONDecoder().decode(ReminderType.self, from: contentJson) else { fatalError() }
      return type
    }
    set {
      (try? JSONEncoder().encode(newValue)).flatMap { contentJson = $0 }
    }
  }
}

extension ReminderEntity {
  // MARK: - Init
  convenience init(
    context: NSManagedObjectContext,
    reminder: Reminder
  ) {
    self.init(context: context)
    uuid = reminder.uuid
    type = reminder.type
  }
  
  func apply(_ reminder: Reminder) {
    uuid = reminder.uuid
    type = reminder.type
  }
}

extension ReminderEntity {
  var model: Reminder {
    .init(uuid: uuid, type: type)
  }
}
