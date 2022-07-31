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
  private let store: RoutineStore
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
  init(store: RoutineStore, itemFactory: RoutineListItemFactory) {
    self.store = store
    self.itemFactory = itemFactory
  }
 
  // MARK: - RoutineListPresenter
  func viewDidLoad() {
    store.observeAll()
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
    addNewRoutine? { [weak self] routine in
      // TODO: - error
      Task { [self] in try await self?.store.save(routine) }
    }
  }
  
  func editRoutine(at section: RoutineList.Section, rowIndex: Int) {
    guard let routine = routine(at: section, rowIndex: rowIndex) else { return }
    
    // swiftlint:disable:next multiline_arguments
    editRoutine?(routine, { [weak self] edited in
      // TODO: - error
      Task { [self] in try await self?.store.update(edited) }
    }, { [weak self] in
      // TODO: - error
      Task { [self] in try await self?.store.delete(routine) }
    })
  }
  
  func deleteRoutine(at section: RoutineList.Section, rowIndex: Int) {
    guard let routine = routine(at: section, rowIndex: rowIndex) else { return }
    // TODO: - error
    Task { try await store.delete(routine) }
  }
  
  func increaseProgress(at section: RoutineList.Section, rowIndex: Int) {
    guard let routine = routine(at: section, rowIndex: rowIndex) else { return }
    var editable = EditableRoutine(routine: routine)
    editable.increaseProgress()
    
    view?.animateProgressUpdate(
      for: editable.progress.percent,
      at: IndexPath(row: rowIndex, section: section.rawValue)
    ) {
      Task { [weak self, editable] in
        // TODO: - error
        try await self?.store.update(editable.routine)
      }
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
    editable.decreaseProgress()
    
    view?.animateProgressUpdate(
      for: editable.progress.percent,
      at: IndexPath(row: rowIndex, section: section.rawValue)
    ) {
      Task { [weak self, editable] in
        // TODO: - error
        try await self?.store.update(editable.routine)
      }
    }
  }
}

// MARK: - Private
extension RoutineListPresenterImpl {
  private func reloadSnapshot(animated: Bool = false) {
    view?.update(
      with: Snapshot {
        itemFactory.daily(
          rows: rows(in: .daily),
          containsAnyItems: !sections.isEmpty
        )
        itemFactory.weekly(rows: rows(in: .weekly))
        itemFactory.monthly(rows: rows(in: .monthly))
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
  
  private func rows(in type: Frequency) -> [RoutineList.Row] {
    routines(in: type)?.map { routine in .init(.routine(.init(routine: routine))) } ?? []
  }
  
  private func routines(in type: Frequency) -> [Routine]? {
    sections.first { $0.type == type }?.routines
  }
}
