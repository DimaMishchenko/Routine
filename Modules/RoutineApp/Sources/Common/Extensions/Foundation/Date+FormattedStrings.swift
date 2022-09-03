import Foundation

extension Date {
  var time: String { DateFormatter.time.string(from: self) }
  var dateShort: String { DateFormatter.dateShort.string(from: self) }
  var dayShort: String { DateFormatter.dayShort.string(from: self) }
  var dayMonth: String { DateFormatter.dayMonth.string(from: self) }
}
