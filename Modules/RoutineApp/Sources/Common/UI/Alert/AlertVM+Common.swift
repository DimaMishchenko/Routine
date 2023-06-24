import Foundation

extension Alert.VM {
  static func deleteAlert(onRemove: @escaping () -> Void) -> Alert.VM {
    .init(
      title: RoutineAppStrings.Localizable.Common.Alert.DeleteRoutine.title,
      message: RoutineAppStrings.Localizable.Common.Alert.DeleteRoutine.message,
      actions: [.cancel, .remove],
      handler: {
        guard case .remove = $0 else { return }
        onRemove()
      }
    )
  }
  
  static func appUpdate(onOpenStore: @escaping () -> Void) -> Alert.VM {
    .init(
      title: RoutineAppStrings.Localizable.Common.Alert.UpdateApp.title,
      message: RoutineAppStrings.Localizable.Common.Alert.UpdateApp.message,
      actions: [.cancel, .yes],
      handler: {
        guard case .yes = $0 else { return }
        onOpenStore()
      }
    )
  }
}
