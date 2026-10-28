import CoreData
import Foundation

@objc(HistoryEntity)
class HistoryEntity: NSManagedObject {
  @NSManaged private(set) var uuid: UUID
  @NSManaged private(set) var date: Date
  @NSManaged private(set) var goal: Int16
  @NSManaged private(set) var result: Int16
  @NSManaged private(set) var routine: RoutineEntity?
}

extension HistoryEntity {
  convenience init(
    context: NSManagedObjectContext,
    history: History
  ) {
    self.init(context: context)
    uuid = history.uuid
    date = history.date
    goal = Int16(history.goal)
    result = Int16(history.result)
  }
}

extension HistoryEntity {
  var model: History {
    History(
      uuid: uuid,
      date: date,
      goal: Int(goal),
      result: Int(result)
    )
  }
}

extension HistoryEntity {
  func update(from history: History) {
    date = history.date
    goal = Int16(history.goal)
    result = Int16(history.result)
  }
}
