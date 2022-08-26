import Foundation

extension Alert.VM {
  static func deleteAlert(onRemove: @escaping () -> Void) -> Alert.VM {
    .init(
      title: RoutineAppStrings.Common.Alert.DeleteRoutine.title,
      message: RoutineAppStrings.Common.Alert.DeleteRoutine.message,
      actions: [.cancel, .remove],
      handler: {
        guard case .remove = $0 else { return }
        onRemove()
      }
    )
  }
}
