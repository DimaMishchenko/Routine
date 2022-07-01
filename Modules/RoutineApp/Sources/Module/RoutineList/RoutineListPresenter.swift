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
  private struct Section {
    let type: Frequency
    let routines: [Routine]
  }
  private var sections: [Section] = []
  private var cancellables: Set<AnyCancellable> = []
  
  // MARK: - Init
  init(provider: RoutineProvider, itemFactory: RoutineListItemFactory) {
    self.provider = provider
    self.itemFactory = itemFactory
  }
 
  // MARK: - RoutineListPresenter
  func viewDidLoad() {
    provider.observeAll()
      .map {
        Dictionary(grouping: $0) { $0.frequency }
          .map { Section(type: $0.key, routines: $0.value.sorted { $0.name < $1.name }) }
      }
      .sink(
        receiveCompletion: {
          guard case .failure(let error) = $0 else { return }
          // TODO: - Error
          print(error)
        },
        receiveValue: { [weak self] in
          self?.sections = $0
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
    view?.update(
      with: Snapshot {
        itemFactory.daily(
          rows: routines(in: .daily)?.map { RoutineList.Row(.routine(.init(routine: $0))) } ?? [],
          containsAnyItems: !sections.isEmpty
        )
        
        itemFactory.weekly(
          rows: routines(in: .weekly)?.map { RoutineList.Row(.routine(.init(routine: $0))) } ?? []
        )
        
        itemFactory.monthly(
          rows: routines(in: .monthly)?.map { RoutineList.Row(.routine(.init(routine: $0))) } ?? []
        )
      },
      animated: animated
    )
  }
  
  private func routine(at section: RoutineList.Section, rowIndex: Int) -> Routine? {
    switch section {
    case .daily:
      return routines(in: .daily)?[safe: rowIndex]
    case .weekly:
      return routines(in: .weekly)?[safe: rowIndex]
    case .monthly:
      return routines(in: .monthly)?[safe: rowIndex]
    }
  }
  
  private func routines(in type: Frequency) -> [Routine]? {
    sections.first { $0.type == type }?.routines
  }
}
