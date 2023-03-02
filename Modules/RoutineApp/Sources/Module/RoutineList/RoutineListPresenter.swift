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
  private let appStateObserver: AppStateObserver
  private let notificationsHandler: NotificationsHandler
  
  // MARK: - Public Properties
  var routineDetails: ((Routine, _ onEdit: @escaping () -> Void) -> Void)?
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
  init(
    store: RoutineStore,
    itemFactory: RoutineListItemFactory,
    appStateObserver: AppStateObserver,
    notificationsHandler: NotificationsHandler
  ) {
    self.store = store
    self.itemFactory = itemFactory
    self.appStateObserver = appStateObserver
    self.notificationsHandler = notificationsHandler
  }
 
  // MARK: - RoutineListPresenter
  func viewDidLoad() {
    clearNotifications()
    
    appStateObserver
      .on(.didBecomeActive)
      .sink { [weak self] in
        self?.clearNotifications()
      }
      .store(in: &cancellables)
    
    store.observeAll()
      .map {
        Dictionary(grouping: $0) { $0.frequency }
          .map { Section(type: $0.key, routines: $0.value.sorted { $0.name < $1.name }) }
      }
      .sink(
        receiveCompletion: {
          guard case .failure(let error) = $0 else { return }
          // TODO: - resubscribe
          Logger.log(error)
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
      Task(logError: true) { [self] in try await self?.store.save(routine) }
    }
  }
  
  func editRoutine(at section: RoutineList.Section, rowIndex: Int) {
    guard let routine = routine(at: section, rowIndex: rowIndex) else { return }
    edit(routine: routine)
  }
  
  func deleteRoutine(at section: RoutineList.Section, rowIndex: Int) {
    guard let routine = routine(at: section, rowIndex: rowIndex) else { return }
    view?.showAlert(
      with: .deleteAlert { [weak self] in
        self?.delete(routine: routine)
      }
    )
  }
  
  func increaseProgress(at section: RoutineList.Section, rowIndex: Int) {
    guard let routine = routine(at: section, rowIndex: rowIndex) else { return }
    var editable = EditableRoutine(routine: routine)
    editable.increaseProgress()
    
    view?.animateProgressUpdate(
      for: RoutineCellVM(routine: editable.routine),
      at: IndexPath(row: rowIndex, section: section.rawValue)
    ) {
      Task(logError: true) { [weak self, editable] in
        try await self?.store.update(editable.routine)
        IntentDonationHandler.donateIncreaseProgress(for: editable.routine)
      }
    }
    
    if editable.progress.goal.rawValue == editable.progress.current {
      view?.showConfetti(with: editable.emoji)
      IntentDonationHandler.donateComplete(editable.routine)
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
      for: RoutineCellVM(routine: editable.routine),
      at: IndexPath(row: rowIndex, section: section.rawValue)
    ) {
      Task(logError: true) { [weak self, editable] in
        try await self?.store.update(editable.routine)
      }
    }
  }
}

// MARK: - Private
extension RoutineListPresenterImpl {
  private func reloadSnapshot() {
    view?.update(
      with: Snapshot {
        itemFactory.daily(
          rows: rows(in: .daily),
          containsAnyItems: !sections.isEmpty
        )
        itemFactory.weekly(rows: rows(in: .weekly))
        itemFactory.monthly(rows: rows(in: .monthly))
      },
      animated: true
    )
  }
  
  private func edit(routine: Routine) {
    // swiftlint:disable:next multiline_arguments
    editRoutine?(routine, { [weak self] edited in
      Task(logError: true) { [self] in try await self?.store.update(edited) }
    }, { [weak self] in
      self?.delete(routine: routine)
    })
  }
  
  private func delete(routine: Routine) {
    routine.reminders.forEach { notificationsHandler.delete($0) }
    Task(logError: true) { try await store.delete(routine) }
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
    routines(in: type)?.map { routine in
      .init(.routine(.init(routine: routine))) { [weak self] in
        self?.routineDetails?(routine) {
          self?.edit(routine: routine)
        }
      }
    } ?? []
  }
  
  private func routines(in type: Frequency) -> [Routine]? {
    sections.first { $0.type == type }?.routines
  }
  
  private func clearNotifications() {
    notificationsHandler.clearDelivered()
  }
}
