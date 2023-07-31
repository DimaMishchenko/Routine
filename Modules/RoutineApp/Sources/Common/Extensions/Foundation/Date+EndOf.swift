import Foundation

extension Date {
  var startOfDay: Date {
    Calendar.app.startOfDay(for: self)
  }

  var endOfDay: Date? {
    var components = DateComponents()
    components.day = 1
    components.second = -1
    return Calendar.app.date(byAdding: components, to: startOfDay)
  }

  var startOfWeek: Date? {
    Calendar.app.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date
  }

  var endOfWeek: Date? {
    var components = DateComponents()
    components.weekOfYear = 1
    components.second = -1
    guard let startOfWeek else { return nil }
    return Calendar.app.date(byAdding: components, to: startOfWeek)
  }

  var startOfMonth: Date? {
    let components = Calendar.app.dateComponents([.year, .month], from: startOfDay)
    return Calendar.app.date(from: components)
  }

  var endOfMonth: Date? {
    var components = DateComponents()
    components.month = 1
    components.second = -1
    guard let startOfMonth else { return nil }
    return Calendar.app.date(byAdding: components, to: startOfMonth)
  }
}
