import Foundation

enum ReminderType {
  case daily(Daily)
//  case weekly(day: Int, hours: Int, minutes: Int)
}

extension ReminderType {
  struct Daily {
    // MARK: - Properties
    let hours: Int
    let minutes: Int
    
    var date: Date? { Calendar.current.date(from: .init(hour: hours, minute: minutes)) }
    
    // MARK: - Init
    static func form(hours: Int, minutes: Int) -> Daily {
      .init(hours: hours, minutes: minutes)
    }
    
    static func from(date: Date) -> Daily {
      let calendar = Calendar.current
      return .init(
        hours: calendar.component(.hour, from: date),
        minutes: calendar.component(.minute, from: date)
      )
    }
  }
}
