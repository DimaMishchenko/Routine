import Foundation

extension Date {
  var byAddingDay: Date? { Calendar.app.date(byAdding: .day, value: 1, to: self) }
  var byAddingWeek: Date? { Calendar.app.date(byAdding: .weekOfYear, value: 1, to: self) }
  var byAddingMonth: Date? { Calendar.app.date(byAdding: .month, value: 1, to: self) }
}
