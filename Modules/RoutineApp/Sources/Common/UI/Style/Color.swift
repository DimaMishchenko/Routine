import UIKit

// MARK: - Color
enum Color {
  static let black = UIColor.black
  static let clear = UIColor.clear
}

// MARK: - Background
extension Color {
  enum Background {}
}

extension Color.Background {
  static let `default`: UIColor = .systemGroupedBackground
  static let secondary: UIColor = .secondarySystemGroupedBackground
  
  static let lightBlue = UIColor(hex: "#D7E9FC")
}

// MARK: - Text
extension Color {
  enum Text {}
}

extension Color.Text {
  static let `default` = UIColor {
    switch $0.userInterfaceStyle {
    case .dark: return .white
    default: return .black
    }
  }
  
  static let value: UIColor = .systemGray
  static let header: UIColor = .systemGray
  static let placeholder: UIColor = .systemGray
  
  static let light: UIColor = .white
}

// MARK: - Button
extension Color {
  enum Button {}
}

extension Color.Button {
  static let `default`: UIColor = .systemBlue
  static let delete: UIColor = .systemRed
  
  static let gray: UIColor = .systemGray
}

// MARK: - Gradient
extension Color {
  enum Gradient {}
}

extension Color.Gradient {
  static let primary = [UIColor(hex: "#80BCFF"), UIColor(hex: "#007AFF")]
  static let secondary = [UIColor(hex: "#FFCA80"), UIColor(hex: "#FF9500")]
}
