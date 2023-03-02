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

// MARK: - Comparable
extension Frequency: Comparable {
  static func < (lhs: Frequency, rhs: Frequency) -> Bool {
    switch (lhs, rhs) {
    case (_, .daily): return false
    case (.monthly, .weekly): return false
    default: return true
    }
  }
}
