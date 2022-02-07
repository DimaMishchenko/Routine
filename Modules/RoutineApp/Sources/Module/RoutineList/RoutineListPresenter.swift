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
  private let itemFactory: RoutineListItemFactory
  
  // MARK: - Public Properties
  var editRoutine: ((Routine, _ completion: @escaping (Routine) -> Void, _ onDelete: @escaping () -> Void) -> Void)?
  var addNewRoutine: ((_ completion: @escaping (Routine) -> Void) -> Void)?
  
  // MARK: - Private Properties
  var routines: [Routine] = []
  
  // MARK: - Init
  init(itemFactory: RoutineListItemFactory) {
    self.itemFactory = itemFactory
  }
 
  // MARK: - RoutineListPresenter
  func viewDidLoad() {
    reloadSnapshot()
  }
  
  func addRoutine() {
    addNewRoutine? { [weak self] in
      self?.routines.append($0)
      self?.reloadSnapshot(animated: true)
    }
  }
  
  func editRoutine(at section: RoutineList.Section, rowIndex: Int) {
    guard
      let routine = routine(at: section, rowIndex: rowIndex),
      let index = routines.firstIndex(of: routine)
    else { return }
    
    // swiftlint:disable:next multiline_arguments
    editRoutine?(routine, { [weak self] in
      self?.routines[index] = $0
      self?.reloadSnapshot()
    }, { [weak self] in
      self?.routines.remove(at: index)
      self?.reloadSnapshot(animated: true)
    })
  }
  
  func deleteRoutine(at section: RoutineList.Section, rowIndex: Int) {
    guard
      let routine = routine(at: section, rowIndex: rowIndex),
      let index = routines.firstIndex(of: routine)
    else { return }
    
    routines.remove(at: index)
    reloadSnapshot(animated: true)
  }
  
  func increaseProgress(at section: RoutineList.Section, rowIndex: Int) {
    guard
      let routine = routine(at: section, rowIndex: rowIndex),
      let currentIndex = routines.firstIndex(of: routine)
    else { return }
    var editable = EditableRoutine(routine: routine)
    editable.progress = Progress(goal: routine.progress.goal, current: routine.progress.current + 1)
    routines[currentIndex] = editable.routine
    reloadSnapshot()
    
    if editable.progress.goal.rawValue == editable.progress.current {
      view?.showConfetti(with: editable.emoji)
    }
  }
  
  func decreaseProgress(at section: RoutineList.Section, rowIndex: Int) {
    guard
      let routine = routine(at: section, rowIndex: rowIndex),
      routine.progress.current != .zero,
      let currentIndex = routines.firstIndex(of: routine)
    else { return }
    var editable = EditableRoutine(routine: routine)
    editable.progress = Progress(goal: routine.progress.goal, current: routine.progress.current - 1)
    routines[currentIndex] = editable.routine
    reloadSnapshot()
  }
}

// MARK: - Private
extension RoutineListPresenterImpl {
  private func reloadSnapshot(animated: Bool = false) {
    let groups = Dictionary(grouping: routines) { $0.frequency }
    
    view?.update(
      with: Snapshot {
        itemFactory.daily(
          rows: groups[.daily]?.map { RoutineList.Row(.routine(.init(routine: $0))) } ?? []
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
