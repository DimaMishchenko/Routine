import UIKit

enum Size {}

extension Size {
  enum CornerRadius {}
}

extension Size.CornerRadius {
  static let container: CGFloat = 14
  static let buttonBig: CGFloat = 14
  static let button: CGFloat = 6
  static let icon: CGFloat = 10
  static let barsInChart: CGFloat = 12
}

extension Size {
  enum View {}
}

extension Size.View {
  static let cellDefault: CGFloat = 44
  static let contentMaxWidth: CGFloat = 760

  static func contentWidth(for availableWidth: CGFloat) -> CGFloat {
    #if targetEnvironment(macCatalyst)
    min(availableWidth, contentMaxWidth)
    #else
    availableWidth > 1100 ? contentMaxWidth : availableWidth
    #endif
  }
}

extension Size {
  enum Button {}
}

extension Size.Button {
  static let big2: CGFloat = 60
  static let big: CGFloat = 50
  static let `default`: CGFloat = 44
  static let small: CGFloat = 24
}

extension Size {
  enum Icon {}
}

extension Size.Icon {
  static let big2: CGFloat = 48
  static let big: CGFloat = 40
  static let `default`: CGFloat = 30
}
