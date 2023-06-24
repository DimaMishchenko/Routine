import Foundation

struct RoutineCellVM: Hashable {
  // MARK: - Public Properties
  var emoji: String { routine.emoji }
  var title: String { routine.name }
  var goal: String { "\(goalFrequencyPrefix()) \(routine.progress.current) / \(routine.progress.goal.rawValue)" }
  var progress: Int { routine.progress.current }
  var progressPercent: Double { routine.progress.percent }
  
  // MARK: - Private Properties
  private let routine: Routine
  
  // MARK: - Init
  init(routine: Routine) {
    self.routine = routine
  }
  
  // MARK: - Private
  private func goalFrequencyPrefix() -> String {
    switch routine.frequency {
    case .daily:
      return RoutineAppStrings.Localizable.RoutineList.Row.Routine.Goal.daily
    case .weekly:
      return RoutineAppStrings.Localizable.RoutineList.Row.Routine.Goal.weekly
    case .monthly:
      return RoutineAppStrings.Localizable.RoutineList.Row.Routine.Goal.monthly
    }
  }
}
