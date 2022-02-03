import UIKit

extension UIImage {
  func alpha(_ alpha: CGFloat) -> UIImage {
    UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { _ in
      draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: alpha)
    }
  }
}
