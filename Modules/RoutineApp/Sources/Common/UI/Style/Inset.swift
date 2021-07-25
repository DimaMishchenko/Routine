import UIKit

enum Inset {}

// MARK: - Side
extension Inset {
  enum Side {}
}

extension Inset.Side {
  static let `default`: CGFloat = 16
  static let small: CGFloat = 8
}
