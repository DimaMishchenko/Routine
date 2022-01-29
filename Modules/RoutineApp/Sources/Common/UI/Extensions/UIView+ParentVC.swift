import UIKit

extension UIView {
  var parentVC: UIViewController? {
    sequence(first: self) { $0.next }
      .first(where: { $0 is UIViewController })
      .flatMap { $0 as? UIViewController }
  }
}
