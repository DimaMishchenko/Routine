import UIKit

extension UIApplication {
  static var keyWindow: UIWindow? {
    UIApplication
    .shared
    .connectedScenes
    .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
    .first { $0.isKeyWindow }
  }
}
