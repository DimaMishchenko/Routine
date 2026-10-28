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
  func select(date: Date)
  func deselect(date: Date)
}

final class RoutineDetailsViewModelImpl: RoutineDetailsViewModel {
  private enum Constants {
    static let barChartMaxItems = 7
  }
  var description: String { routine.description }
  @Published private(set) var statsVMs: [StatsViewModel] = []
  @Published private(set) var calendarVM = CalendarVM(selections: [])
  @Published private(set) var barChartVM = BarChartVM(entries: [])
  @Published private(set) var lineChartVM = LineChartVM(entries: [])
  @Published private(set) var successRate: Double = .zero
  var editRoutine: (() -> Void)?
  var dismiss: (() -> Void)?
  var showAlert: ((Alert.VM) -> Void)?
  private let routineStore: RoutineStore
  private var routine: Routine
  init(routine: Routine, routineStore: RoutineStore) {
    self.routine = routine
    self.routineStore = routineStore
  }
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

  func select(date: Date) {
    guard date < Date(), !date.isInToday else { return }
    
    adjustProgress(with: RoutineAppStrings.Localizable.RoutineDetails.Alert.ProgressAdjust.Description.add) {
      $0.history.append(
        .init(uuid: UUID(), date: date, goal: routine.progress.goal.rawValue, result: routine.progress.goal.rawValue)
      )
    }
  }

  func deselect(date: Date) {
    guard
      !date.isInToday,
      let history = routine.history.first(where: { $0.date.isInSameDay(as: date) })
    else { return }
    let routineID = routine.uuid
    showAlert?(
      adjustProgressAlertVM(
        message: RoutineAppStrings.Localizable.RoutineDetails.Alert.ProgressAdjust.Description.remove,
        onConfirm: { [weak self] in
          guard let self else { return }
          Task(priority: .userInitiated) {
            do {
              try await self.routineStore.removeHistory(id: history.uuid, from: routineID)
              let savedRoutines = try await self.routineStore.allRoutines()
              self.routine = savedRoutines.first(where: { $0.uuid == routineID }) ?? self.routine
              self.loadDetails()
            } catch {
              self.showAlert?(self.adjustFailedAlertVM())
              Logger.log(error)
            }
          }
        }
      )
    )
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
        title: "\(currentStreak) \(RoutineAppStrings.Localizable.Common.times)",
        description: RoutineAppStrings.Localizable.RoutineDetails.Text.currentStreak
      ),
      .init(
        image: RoutineAppAsset.Icon.bestStreak.image,
        title: "\(bestStreak) \(RoutineAppStrings.Localizable.Common.times)",
        description: RoutineAppStrings.Localizable.RoutineDetails.Text.bestStreak
      ),
      .init(
        image: RoutineAppAsset.Icon.missedDays.image,
        title: "\(skippedDays) \(RoutineAppStrings.Localizable.Common.times)",
        description: RoutineAppStrings.Localizable.RoutineDetails.Text.missedTimes
      ),
      .init(
        image: RoutineAppAsset.Icon.currentStreak.image,
        title: routine.startDate.dateShort.capitalized,
        description: RoutineAppStrings.Localizable.RoutineDetails.Text.startDate
      )
    ]
  }

  private func loadCalendar() {
    calendarVM = CalendarVM(
      selections: routine.history
        .map { item in
          let emoji: String = {
            if item.goalAchieved {
              return routine.emoji
            } else if item.result == .zero {
              return "❌"
            } else {
              return "⚪️"
            }
          }()
          return .init(emoji: emoji, date: item.date)
        }
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
    guard everyDayRates.count != .zero else {
      successRate = .zero
      return
    }
    successRate = everyDayRates.reduce(into: .zero, { $0 += $1 }) / Double(everyDayRates.count)
  }

  private func adjustProgress(
    with message: String,
    adjust: (inout EditableRoutine) -> Void
  ) {
    var editable = EditableRoutine(routine: routine)
    adjust(&editable)

    showAlert?(
      adjustProgressAlertVM(
        message: message,
        onConfirm: { [weak self] in
          self?.updateRoutineAndReload(editable.routine)
        }
      )
    )
  }

  private func updateRoutineAndReload(_ routine: Routine) {
    Task(priority: .userInitiated) {
      do {
        try await routineStore.update(routine)
        self.routine = routine
        loadDetails()
      } catch {
        showAlert?(adjustFailedAlertVM())
        Logger.log(error)
      }
    }
  }

  private func adjustProgressAlertVM(message: String, onConfirm: @escaping () -> Void) -> Alert.VM {
    .init(
      title: RoutineAppStrings.Localizable.RoutineDetails.Alert.ProgressAdjust.title,
      message: message,
      actions: [.yes, .cancel]
    ) {
      guard case .yes = $0 else { return }
      onConfirm()
    }
  }

  private func adjustFailedAlertVM() -> Alert.VM {
    .init(
      title: RoutineAppStrings.Localizable.RoutineDetails.Alert.AdjustError.title,
      message: RoutineAppStrings.Localizable.RoutineDetails.Alert.AdjustError.description,
      actions: [.ok],
      handler: { _ in }
    )
  }
}
