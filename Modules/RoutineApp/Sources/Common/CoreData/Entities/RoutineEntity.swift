import CoreData
import Foundation

@objc(RoutineEntity)
class RoutineEntity: NSManagedObject {
  @NSManaged private(set) var uuid: UUID
  @NSManaged private(set) var name: String
  @NSManaged private(set) var desc: String
  @NSManaged private(set) var emoji: String
  @NSManaged private(set) var startDate: Date
  @NSManaged private var frequency: Int16
  @NSManaged private(set) var progress: ProgressEntity?
  @NSManaged private(set) var remind: Bool
  @NSManaged private(set) var reminders: Set<ReminderEntity>?
  @NSManaged private(set) var history: Set<HistoryEntity>?
  @NSManaged private(set) var lastUpdateDate: Date
  
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
    history = Set(routine.history.map { HistoryEntity(context: context, history: $0) })
    lastUpdateDate = Date()
  }
  
  func append(_ history: HistoryEntity) {
    self.history?.insert(history)
  }
}

extension RoutineEntity {
  var model: Routine? {
    guard
      let progress = progress,
      let reminders = reminders,
      let history = history
    else { return nil }
    
    return Routine(
      uuid: uuid,
      name: name,
      description: desc,
      emoji: emoji,
      startDate: startDate,
      frequency: frequencyType,
      progress: progress.model,
      remind: remind,
      reminders: reminders.map { $0.model },
      history: history.map { $0.model }
    )
  }
}

extension RoutineEntity {
  func update(from routine: Routine) {
    name = routine.name
    desc = routine.description
    emoji = routine.emoji
    frequencyType = routine.frequency
    remind = routine.remind
    lastUpdateDate = Date()
    guard let context = managedObjectContext else { return }
    if let progress = progress {
      progress.update(from: routine.progress)
    } else {
      progress = ProgressEntity(context: context, progress: routine.progress)
    }
    let existingReminders = reminders ?? []
    for reminder in existingReminders where !routine.reminders.contains(where: { $0.uuid == reminder.uuid }) {
      context.delete(reminder)
    }
    reminders = Set(routine.reminders.map { value in
      if let existing = existingReminders.first(where: { $0.uuid == value.uuid }) {
        existing.type = value.type
        return existing
      }
      return ReminderEntity(context: context, reminder: value)
    })
    var savedHistory = history ?? []
    for value in routine.history {
      if let existing = savedHistory.first(where: { $0.uuid == value.uuid }) {
        existing.update(from: value)
      } else {
        savedHistory.insert(HistoryEntity(context: context, history: value))
      }
    }
    history = savedHistory
  }
}
