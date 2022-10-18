import Foundation

extension Date {
  func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .app) -> Bool {
    calendar.isDate(self, equalTo: date, toGranularity: component)
  }
  
  func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
  func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
  func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }
  
  func isInSameDay(as date: Date) -> Bool { Calendar.app.isDate(self, inSameDayAs: date) }
  
  var isInThisYear: Bool { isInSameYear(as: Date()) }
  var isInThisMonth: Bool { isInSameMonth(as: Date()) }
  var isInThisWeek: Bool { isInSameWeek(as: Date()) }
  
  var isInYesterday: Bool { Calendar.app.isDateInYesterday(self) }
  var isInToday: Bool { Calendar.app.isDateInToday(self) }
  var isInTomorrow: Bool { Calendar.app.isDateInTomorrow(self) }
  
  var isInTheFuture: Bool { self > Date() }
  var isInThePast: Bool { self < Date() }
}
