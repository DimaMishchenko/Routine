import Foundation

struct EditableRoutine {
  let uuid: UUID
  var name: String
  var description: String
  var emoji: String
  let startDate: Date
  var frequency: Frequency
  var progress: Progress { didSet { syncTodaysHistoryWithProgress() } }
  var remind: Bool
  var reminders: [Reminder]
  var history: [History]
  
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
    history = routine.history
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
      reminders: reminders,
      history: history
    )
  }
  
  mutating func increaseProgress() {
    updateProgress(byAdding: 1)
  }
  
  mutating func decreaseProgress() {
    guard progress.current != .zero else { return }
    updateProgress(byAdding: -1)
  }
  
  private mutating func updateProgress(byAdding update: Int) {
    progress = Progress(goal: progress.goal, current: progress.current + update)
  }
  
  private mutating func syncTodaysHistoryWithProgress() {
    updateTodaysHistory { [progress] in
      History(uuid: $0.uuid, date: $0.date, goal: progress.goal.rawValue, result: progress.current)
    }
  }
  
  private mutating func updateTodaysHistory(updater: (_ current: History) -> History) {
    history
      .firstIndex { $0.date.isInToday }
      .flatMap { history[$0] = updater(history[$0]) }
  }
}
