import Foundation

extension Date {
  var withoutTime: Date? {
    let calendar = Calendar.app
    guard let date = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: self)) else {
      return nil
    }
    return date
  }
}
