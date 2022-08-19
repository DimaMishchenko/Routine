import UIKit

enum Size {}

// MARK: - CornerRadius
extension Size {
  enum CornerRadius {}
}

extension Size.CornerRadius {
  static let container: CGFloat = 14
  static let buttonBig: CGFloat = 14
  static let button: CGFloat = 6
}

// MARK: - View
extension Size {
  enum View {}
}

extension Size.View {
  static let cellDefault: CGFloat = 44
}

// MARK: - Button
extension Size {
  enum Button {}
}

extension Size.Button {
  static let big: CGFloat = 50
  static let `default`: CGFloat = 44
  static let small: CGFloat = 24
}

// MARK: - Icon
extension Size {
  enum Icon {}
}

extension Size.Icon {
  static let big: CGFloat = 48
  static let `default`: CGFloat = 30
}
