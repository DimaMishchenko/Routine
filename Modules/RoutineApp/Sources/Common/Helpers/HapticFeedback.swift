import UIKit

enum HapticFeedback {
  static func select() {
    UISelectionFeedbackGenerator().selectionChanged()
  }
  
  static func success() {
    UINotificationFeedbackGenerator().notificationOccurred(.success)
  }
}
