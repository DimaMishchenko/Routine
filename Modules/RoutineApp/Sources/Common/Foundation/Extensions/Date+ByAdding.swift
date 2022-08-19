import Foundation

extension Date {
  var byAddingDay: Date? { Calendar.current.date(byAdding: .day, value: 1, to: self) }
  var byAddingWeek: Date? { Calendar.current.date(byAdding: .weekOfYear, value: 1, to: self) }
  var byAddingMonth: Date? { Calendar.current.date(byAdding: .month, value: 1, to: self) }
}
