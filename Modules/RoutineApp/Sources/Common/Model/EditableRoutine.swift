import Foundation

struct EditableRoutine {
  let uuid: UUID
  var name: String
  var description: String
  var emoji: String
  let startDate: Date
  var frequency: Frequency
  var progress: Progress
  var remind: Bool
  var reminders: [Reminder]
  
  init(routine: Routine) {
    uuid = routine.uuid
    name = routine.name
    description = routine.description
    emoji = routine.emoji
    startDate = routine.startDate
    frequency = routine.frequency
    progress = routine.progress
    remind = routine.remind
    reminders = routine.reminders
  }
  
  var routine: Routine {
    Routine(
      uuid: uuid,
      name: name,
      description: description,
      emoji: emoji,
      startDate: startDate,
      frequency: frequency,
      progress: progress,
      remind: remind,
      reminders: reminders
    )
  }
}
