import Combine
import Foundation
import SPConfetti
import UIKit

protocol RoutineListPresenter {
  func viewDidLoad()
  func addRoutine()
  func editRoutine(at section: RoutineList.Section, rowIndex: Int)
  func deleteRoutine(at section: RoutineList.Section, rowIndex: Int)
  func increaseProgress(at section: RoutineList.Section, rowIndex: Int)
  func decreaseProgress(at section: RoutineList.Section, rowIndex: Int)
}

final class RoutineListPresenterImpl: RoutineListPresenter {
  // MARK: - Dependencies
  weak var view: RoutineListViewInterface?
  private let provider: RoutineProvider
  private let itemFactory: RoutineListItemFactory
  
  // MARK: - Public Properties
  var editRoutine: ((Routine, _ completion: @escaping (Routine) -> Void, _ onDelete: @escaping () -> Void) -> Void)?
  var addNewRoutine: ((_ completion: @escaping (Routine) -> Void) -> Void)?
  
  // MARK: - Private Properties
  private var routines: [Routine] = []
  private var cancellables: Set<AnyCancellable> = []
  
  // MARK: - Init
  init(provider: RoutineProvider, itemFactory: RoutineListItemFactory) {
    self.provider = provider
    self.itemFactory = itemFactory
  }
 
  // MARK: - RoutineListPresenter
  func viewDidLoad() {
    provider.observeAll()
      .sink(
        receiveCompletion: {
          guard case .failure(let error) = $0 else { return }
          // TODO: - Error
          print(error)
        },
        receiveValue: { [weak self] in
          self?.routines = $0
          self?.reloadSnapshot()
        }
      )
      .store(in: &cancellables)
  }
  
  func addRoutine() {
    addNewRoutine? { routine in
      Task { [weak self] in
        // TODO: - error
        try await self?.provider.save(routine)
      }
    }
  }
  
  func editRoutine(at section: RoutineList.Section, rowIndex: Int) {
    guard let routine = routine(at: section, rowIndex: rowIndex) else { return }
    
    // swiftlint:disable:next multiline_arguments
    editRoutine?(routine, { edited in
      // TODO: - error
      Task { [weak self] in try await self?.provider.update(edited) }
    }, {
      // TODO: - error
      Task { [weak self] in try await self?.provider.delete(routine) }
    })
  }
  
  func deleteRoutine(at section: RoutineList.Section, rowIndex: Int) {
    guard let routine = routine(at: section, rowIndex: rowIndex) else { return }
    // TODO: - error
    Task { [weak self] in try await self?.provider.delete(routine) }
  }
  
  func increaseProgress(at section: RoutineList.Section, rowIndex: Int) {
    guard let routine = routine(at: section, rowIndex: rowIndex) else { return }
    var editable = EditableRoutine(routine: routine)
    editable.progress = Progress(goal: routine.progress.goal, current: routine.progress.current + 1)
    
    // TODO: - error
    Task { [weak self, editable] in
      try await self?.provider.update(editable.routine)
    }
    
    if editable.progress.goal.rawValue == editable.progress.current {
      view?.showConfetti(with: editable.emoji)
    }
  }
  
  func decreaseProgress(at section: RoutineList.Section, rowIndex: Int) {
    guard
      let routine = routine(at: section, rowIndex: rowIndex),
      routine.progress.current != .zero
    else { return }
    var editable = EditableRoutine(routine: routine)
    editable.progress = Progress(goal: routine.progress.goal, current: routine.progress.current - 1)
    // TODO: - error
    Task { [weak self, editable] in
      try await self?.provider.update(editable.routine)
    }
  }
}

// MARK: - Private
extension RoutineListPresenterImpl {
  private func reloadSnapshot(animated: Bool = false) {
    let groups = Dictionary(grouping: routines) { $0.frequency }
    
    view?.update(
      with: Snapshot {
        itemFactory.daily(
          rows: groups[.daily]?.map { RoutineList.Row(.routine(.init(routine: $0))) } ?? [],
          containsAnyItems: !routines.isEmpty
        )
        
        itemFactory.weekly(
          rows: groups[.weekly]?.map { RoutineList.Row(.routine(.init(routine: $0))) } ?? []
        )
        
        itemFactory.monthly(
          rows: groups[.monthly]?.map { RoutineList.Row(.routine(.init(routine: $0))) } ?? []
        )
      },
      animated: animated
    )
  }
  
  private func routine(at section: RoutineList.Section, rowIndex: Int) -> Routine? {
    let groups = Dictionary(grouping: routines) { $0.frequency }
    
    switch section {
    case .daily:
      return groups[.daily]?[safe: rowIndex]
    case .weekly:
      return groups[.weekly]?[safe: rowIndex]
    case .monthly:
      return groups[.monthly]?[safe: rowIndex]
    }
  }
}
