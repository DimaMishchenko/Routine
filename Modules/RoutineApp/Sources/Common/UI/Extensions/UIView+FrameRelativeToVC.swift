import UIKit

extension UIView {
  var frameRelativeToVC: CGRect? {
    superview?.convert(frame, to: parentVC?.view)
  }
}
