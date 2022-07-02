import Foundation

extension Date {
  func compare(with date: Date, to granularity: Calendar.Component) -> Bool {
    Calendar.current.compare(self, to: date, toGranularity: granularity) == .orderedSame
  }
  
  func compareWithToday(to granularity: Calendar.Component) -> Bool {
    compare(with: Date(), to: granularity)
  }
}
