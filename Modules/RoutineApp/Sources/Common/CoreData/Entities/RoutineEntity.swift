import CoreData
import Foundation

@objc(RoutineEntity)
class RoutineEntity: NSManagedObject {
  // MARK: - Properties
  @NSManaged private(set) var uuid: UUID
  @NSManaged private(set) var name: String
  @NSManaged private(set) var desc: String
  @NSManaged private(set) var emoji: String
  @NSManaged private(set) var startDate: Date
  @NSManaged private var frequency: Int16
  @NSManaged private(set) var progress: ProgressEntity
  @NSManaged private(set) var remind: Bool
  @NSManaged private(set) var reminders: Set<ReminderEntity>
  
  var frequencyType: Frequency {
    get {
      guard let frequency = Frequency(rawValue: Int(frequency)) else { fatalError() }
      return frequency
    }
    set {
      frequency = Int16(newValue.rawValue)
    }
  }
}

extension RoutineEntity {
  // MARK: - Init
  convenience init(
    context: NSManagedObjectContext,
    routine: Routine
  ) {
    self.init(context: context)
    uuid = routine.uuid
    name = routine.name
    desc = routine.description
    emoji = routine.emoji
    startDate = routine.startDate
    frequencyType = routine.frequency
    progress = ProgressEntity(context: context, progress: routine.progress)
    remind = routine.remind
    reminders = Set(routine.reminders.map { ReminderEntity(context: context, reminder: $0) })
  }
  
  func apply(_ routine: Routine) {
    uuid = routine.uuid
    name = routine.name
    desc = routine.description
    emoji = routine.emoji
    startDate = routine.startDate
    frequency = Int16(routine.frequency.rawValue)
    progress.apply(routine.progress)
    remind = routine.remind
    reminders.forEach { reminder in
      guard let update = routine.reminders.first(where: { $0.uuid == reminder.uuid }) else { return }
      reminder.apply(update)
    }
  }
}

extension RoutineEntity {
  var model: Routine {
    Routine(
      uuid: uuid,
      name: name,
      description: description,
      emoji: emoji,
      startDate: startDate,
      frequency: frequencyType,
      progress: progress.model,
      remind: remind,
      reminders: reminders.map { $0.model }
    )
  }
}
