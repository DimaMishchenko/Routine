import Foundation

extension DateFormatter {
  static let time = with(DateFormatter()) {
    $0.timeStyle = .short
    $0.dateStyle = .none
  }
  
  static let dateShort = with(DateFormatter()) {
    $0.dateFormat = "MMM d, yyyy"
  }
  
  static let dayShort = with(DateFormatter()) {
    $0.dateFormat = "E"
  }
  
  static let dayMonth = with(DateFormatter()) {
    $0.dateFormat = "dd.MM"
  }
}
