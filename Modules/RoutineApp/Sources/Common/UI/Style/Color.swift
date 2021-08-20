import UIKit

// MARK: - Color
enum Color {}

// MARK: - Background
extension Color {
  enum Background {}
}

extension Color.Background {
  static let `default`: UIColor = .systemGroupedBackground
  static let secondary: UIColor = .secondarySystemGroupedBackground
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
}

// MARK: - Button
extension Color {
  enum Button {}
}

extension Color.Button {
  static let `default`: UIColor = .systemBlue
}
