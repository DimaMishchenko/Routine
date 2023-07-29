import Foundation

extension Date {
  var endOfWeek: Date? {
    let gregorian = Calendar.app
    guard let sunday = gregorian.date(
      from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
    ) else { return nil }
    return gregorian.date(byAdding: .day, value: 7, to: sunday)
  }

  var endOfMonth: Date? {
    guard let start = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) else {
      return nil
    }
    return Calendar.app.date(byAdding: DateComponents(month: 1, day: -1), to: start)
  }
}
