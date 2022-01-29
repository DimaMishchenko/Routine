import Foundation

protocol RoutineEditSectionFactory {
  typealias Section = Snapshot<RoutineEdit.Section, RoutineEdit.Row>.Item
  
  func emojiSection(emoji: String, action: @escaping () -> Void) -> Section
  func frequencySection(frequency: Frequency, action: @escaping () -> Void) -> Section
  func goalSection(goal: Progress.Goal, action: @escaping () -> Void) -> Section
}

final class RoutineEditSectionFactoryImpl: RoutineEditSectionFactory {
  func emojiSection(emoji: String, action: @escaping () -> Void) -> Section {
    .init(section: .emoji, rows: [
      .init(
        .value(.init(title: RoutineAppStrings.RoutineEdit.Text.emoji, value: .emoji(emoji))),
        action: action
      )
    ])
  }
  
  func frequencySection(frequency: Frequency, action: @escaping () -> Void) -> Section {
    .init(section: .frequency, rows: [
      .init(
        .value(.init(title: RoutineAppStrings.RoutineEdit.Text.frequency, value: .text(frequency.localized))),
        action: action
      )
    ])
  }
  
  func goalSection(goal: Progress.Goal, action: @escaping () -> Void) -> Section {
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
