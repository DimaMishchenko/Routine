import Foundation

extension DateFormatter {
  static let time = with(DateFormatter()) {
    $0.timeStyle = .short
    $0.dateStyle = .none
  }
}
