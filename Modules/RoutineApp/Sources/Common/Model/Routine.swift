import Foundation

struct Routine: Hashable {
  let uuid: UUID
  let name: String
  let description: String
  let emoji: String
  let startDate: Date
  let frequency: Frequency
  let progress: Progress
  let remind: Bool
  let reminders: [Reminder]
  let history: [History]
}

extension Routine {
  static var new: Routine {
    Routine(
      uuid: UUID(),
      name: .empty,
      description: .empty,
      emoji: "😀",
      startDate: Date(),
      frequency: .daily,
      progress: Progress(goal: .min, current: .zero),
      remind: false,
      reminders: [],
      history: [History(uuid: UUID(), date: Date(), goal: Progress.Goal.min.rawValue, result: .zero)]
    )
  }
}
