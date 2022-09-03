import Foundation

@MainActor protocol RoutineDetailsViewModel: ObservableObject {
  var description: String { get }
  var statsVMs: [StatsViewModel] { get }
  var calendarVM: CalendarVM { get }
  var barChartVM: BarChartVM { get }
  var lineChartVM: LineChartVM { get }
  var successRate: Double { get }
  
  func close()
  func edit()
  func loadDetails()
}

final class RoutineDetailsViewModelImpl: RoutineDetailsViewModel {
  // MARK: - Constants
  private enum Constants {
    static let barChartMaxItems = 7
  }
  
  // MARK: - Public Properties
  var description: String { routine.description }
  @Published private(set) var statsVMs: [StatsViewModel] = []
  @Published private(set) var calendarVM = CalendarVM(selections: [])
  @Published private(set) var barChartVM = BarChartVM(entries: [])
  @Published private(set) var lineChartVM = LineChartVM(entries: [])
  @Published private(set) var successRate: Double = .zero
  
  // MARK: - Action Properties
  var editRoutine: (() -> Void)?
  var dismiss: (() -> Void)?
  
  private let routine: Routine
  
  // MARK: - Init
  init(routine: Routine) {
    self.routine = routine
  }
  
  // MARK: - Public
  func close() { dismiss?() }
  
  func edit() {
    dismiss?()
    editRoutine?()
  }
  
  func loadDetails() {
    Task(priority: .userInitiated) {
      loadStats()
      loadCalendar()
      loadCharts()
      loadSuccessRate()
    }
  }
  
  private func loadStats() {
    var successDays: Int = .zero
    var skippedDays: Int = .zero
    
    var currentStreak: Int = .zero
    var bestStreak: Int = .zero
    
    routine.history.sorted(by: { $0.date < $1.date }).forEach {
      if $0.goalAchieved {
        successDays += 1
        currentStreak += 1
      } else if !$0.date.isInToday {
        currentStreak = .zero
      }
      
      if currentStreak > bestStreak { bestStreak = currentStreak }
      if $0.result == .zero, !$0.date.isInToday { skippedDays += 1 }
    }
    
    statsVMs = [
      .init(
        image: RoutineAppAsset.Icon.currentStreak.image,
        title: "\(currentStreak) \(RoutineAppStrings.Common.times)",
        description: RoutineAppStrings.RoutineDetails.Text.currentStreak
      ),
      .init(
        image: RoutineAppAsset.Icon.bestStreak.image,
        title: "\(bestStreak) \(RoutineAppStrings.Common.times)",
        description: RoutineAppStrings.RoutineDetails.Text.bestStreak
      ),
      .init(
        image: RoutineAppAsset.Icon.missedDays.image,
        title: "\(skippedDays) \(RoutineAppStrings.Common.times)",
        description: RoutineAppStrings.RoutineDetails.Text.missedTimes
      ),
      .init(
        image: RoutineAppAsset.Icon.currentStreak.image,
        title: routine.startDate.dateShort.capitalized,
        description: RoutineAppStrings.RoutineDetails.Text.startDate
      )
    ]
  }
  
  private func loadCalendar() {
    calendarVM = CalendarVM(
      selections: routine.history
        .filter { $0.goalAchieved }
        .map { .init(emoji: routine.emoji, date: $0.date) }
    )
  }
  
  private func loadCharts() {
    let history = routine.history.sorted(by: { $0.date < $1.date })
    
    barChartVM = .init(
      entries: history.prefix(Constants.barChartMaxItems).map {
        .init(
          title: routine.frequency == .daily ? $0.date.dayShort : $0.date.dayMonth,
          value: Double($0.result)
        )
      }
    )
    
    lineChartVM = .init(entries: history.map { .init(title: $0.date.dayMonth, value: Double($0.result)) })
  }
  
  private func loadSuccessRate() {
    let everyDayRates = routine.history.map { $0.goalAchieved ? 1 : (Double($0.result) / Double($0.goal)) }
    successRate = everyDayRates.reduce(into: .zero, { $0 += $1 }) / Double(everyDayRates.count)
  }
}
