import UIKit

enum Inset {}

// MARK: - Side
extension Inset {
  enum Padding {}
}

extension Inset.Padding {
  static let `default`: CGFloat = 16
  static let small: CGFloat = 8
  
  static let smedium: CGFloat = 10
}
