import Foundation

protocol RoutineEditItemFactory {
  typealias Item = Snapshot<RoutineEdit.Section, RoutineEdit.Row>.Item
  
  func emoji(with emoji: String, action: @escaping () -> Void) -> Item
  func frequency(with frequency: Frequency, action: @escaping () -> Void) -> Item
  func goal(with goal: Progress.Goal, action: @escaping () -> Void) -> Item
}

final class RoutineEditItemFactoryImpl: RoutineEditItemFactory {
  func emoji(with emoji: String, action: @escaping () -> Void) -> Item {
    .init(section: .emoji, rows: [
      .init(
        .value(.init(title: RoutineAppStrings.RoutineEdit.Text.emoji, value: .emoji(emoji))),
        action: action
      )
    ])
  }
  
  func frequency(with frequency: Frequency, action: @escaping () -> Void) -> Item {
    .init(section: .frequency, rows: [
      .init(
        .value(.init(title: RoutineAppStrings.RoutineEdit.Text.frequency, value: .text(frequency.localized))),
        action: action
      )
    ])
  }
  
  func goal(with goal: Progress.Goal, action: @escaping () -> Void) -> Item {
    .init(section: .goal, rows: [
      .init(
        .value(
          .init(
            title: RoutineAppStrings.RoutineEdit.Text.goal,
            value: .text("\(goal.rawValue) \(RoutineAppStrings.RoutineEdit.Text.timePerDay)")
          )
        ),
        action: action
      )
    ])
  }
}
