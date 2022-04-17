import UIKit

enum Font {}

// MARK: - Size
extension Font {
  public struct Size: RawRepresentable {
    let rawValue: CGFloat
  }
}

extension Font.Size: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Float) { rawValue = CGFloat(value) }
}

extension Font.Size: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int) { rawValue = CGFloat(value) }
}

extension Font.Size {
  static let largeTitle: Font.Size = 34
  static let title1: Font.Size = 28
  static let title2: Font.Size = 22
  static let title3: Font.Size = 20
  static let headline: Font.Size = 17
  static let body: Font.Size = 17
  static let callout: Font.Size = 16
  static let subhead: Font.Size = 15
  static let footnote: Font.Size = 13
  static let caption1: Font.Size = 12
  static let caption2: Font.Size = 11
  static let caption3: Font.Size = 10
}

// MARK: - System
extension Font {
  static func system(_ size: Font.Size, weight: UIFont.Weight) -> UIFont {
    let font = UIFont.systemFont(ofSize: size.rawValue, weight: weight)
    return UIFontMetrics.default.scaledFont(
      for: font.fontDescriptor.withDesign(.rounded).flatMap { UIFont(descriptor: $0, size: size.rawValue) } ?? font
    )
  }
}
