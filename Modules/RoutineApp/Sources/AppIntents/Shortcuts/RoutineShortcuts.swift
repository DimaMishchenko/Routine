import AppIntents
import Foundation

struct RoutineShortcuts: AppShortcutsProvider {
  @AppShortcutsBuilder static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: CompleteRoutinesIntent(),
      phrases: ["Complete \(.applicationName)"],
      shortTitle: "intent.CR.title",
      systemImageName: "text.badge.checkmark"
    )
    AppShortcut(
      intent: IncreaseRoutinesProgressIntent(),
      phrases: ["Increase \(.applicationName) progress"],
      shortTitle: "intent.IRP.title",
      systemImageName: "text.badge.plus"
    )
  }

  static let shortcutTileColor: ShortcutTileColor = .navy
}
