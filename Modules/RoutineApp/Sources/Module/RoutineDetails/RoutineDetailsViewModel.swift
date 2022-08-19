import Foundation

@MainActor protocol RoutineDetailsViewModel {
  var description: String { get }
  var statsModels: [StatsViewModel] { get }
  
  func close()
  func edit()
  func loadStats()
}

final class RoutineDetailsViewModelImpl: RoutineDetailsViewModel, ObservableObject {
  // MARK: - Public Properties
  var description: String { routine.description }
  
  var statsModels: [StatsViewModel] {
    [
      .init(image: RoutineAppAsset.Icon.add.image, title: "4 days", description: "Total Done"),
      .init(image: RoutineAppAsset.Icon.add.image, title: "3 days", description: "Best Streak"),
      .init(image: RoutineAppAsset.Icon.add.image, title: "2 days", description: "Kekwaits"),
      .init(image: RoutineAppAsset.Icon.add.image, title: "1 days", description: "Missed")
    ]
  }
  
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
  
  func loadStats() {
    Task(priority: .userInitiated) {
      let daysSinceStared = routine.startDate.daysBetween(Date()) ?? .zero
      
      var successDays: Int = .zero
      var skippedDays: Int = .zero
      
      var currentStreak: Int = .zero
      var bestStreak: Int = .zero
      
      routine.history.forEach {
        if $0.result >= $0.goal {
          successDays += 1
          currentStreak += 1
        } else {
          if currentStreak > bestStreak { bestStreak = currentStreak }
          currentStreak = .zero
        }
        
        if $0.result == .zero {
          skippedDays += 1
        }
      }
    }
  }
}
