import Foundation

protocol RoutineEditItemFactory {
  typealias Item = Snapshot<RoutineEdit.Section, RoutineEdit.Row>.Item
  
  func emoji(with emoji: String, action: @escaping () -> Void) -> Item
  func frequency(with frequency: Frequency) -> Item
  func goal(with goal: Progress.Goal) -> Item
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
  
  func frequency(with frequency: Frequency) -> Item {
    .init(section: .frequency, rows: [
      .init(
        .frequencyPicker(
          .init(
            title: RoutineAppStrings.RoutineEdit.Text.frequency,
            values: Frequency.allCases,
            selected: frequency,
            style: .menu
          )
        )
      )
    ])
  }
  
  func goal(with goal: Progress.Goal) -> Item {
    .init(section: .goal, rows: [
      .init(
        .goalPicker(
          .init(
            title: RoutineAppStrings.RoutineEdit.Text.goal,
            values: .init(Progress.Goal.min...Progress.Goal.max),
            selected: goal,
            style: .wheel
          )
        )
      )
    ])
  }
}
