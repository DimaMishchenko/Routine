import Foundation

extension Date {
  var time: String { DateFormatter.time.string(from: self) }
}
