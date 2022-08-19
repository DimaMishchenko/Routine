import UIKit

enum Inset {}

// MARK: - Side
extension Inset {
  enum Padding {}
}

extension Inset.Padding {
  static let big: CGFloat = 32
  static let `default`: CGFloat = 16
  static let small: CGFloat = 8
  static let extraSmall: CGFloat = 4
  
  static let smedium: CGFloat = 10
}
