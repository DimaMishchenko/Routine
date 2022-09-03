import UIKit

extension UIApplication {
  var activeWindowScene: UIWindowScene? {
    connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene 
  }
}
