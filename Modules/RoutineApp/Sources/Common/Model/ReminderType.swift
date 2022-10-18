import Foundation

enum ReminderType: Hashable, Codable {
  case daily(Daily)
//  case weekly(day: Int, hours: Int, minutes: Int)
}

extension ReminderType {
  struct Daily: Hashable, Codable {
    // MARK: - Properties
    let hours: Int
    let minutes: Int
    
    var date: Date? { Calendar.app.date(from: .init(hour: hours, minute: minutes)) }
    
    // MARK: - Init
    static func form(hours: Int, minutes: Int) -> Daily {
      .init(hours: hours, minutes: minutes)
    }
    
    static func from(date: Date) -> Daily {
      let calendar = Calendar.app
      return .init(
        hours: calendar.component(.hour, from: date),
        minutes: calendar.component(.minute, from: date)
      )
    }
  }
}

// MARK: - ReminderType + Codable
extension ReminderType {
  private enum ReminderTypePlain: String, Codable {
    case daily
  }
  
  private enum CodingKeys: String, CodingKey {
    case type
    case body
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    switch try container.decode(ReminderTypePlain.self, forKey: .type) {
    case .daily:
      let daily = try container.decode(Daily.self, forKey: .body)
      self = .daily(daily)
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .daily(let daily):
      try container.encode(ReminderTypePlain.daily, forKey: .type)
      try container.encode(daily, forKey: .body)
    }
  }
}
