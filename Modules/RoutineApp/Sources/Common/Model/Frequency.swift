import Foundation

enum Frequency: Int, Hashable, CaseIterable {
  case daily
  case weekly
  case monthly
}

// MARK: - Localized
extension Frequency {
  var localized: String {
    switch self {
    case .daily: return RoutineAppStrings.Frequency.daily
    case .weekly: return RoutineAppStrings.Frequency.weekly
    case .monthly: return RoutineAppStrings.Frequency.monthly
    }
  }
}
