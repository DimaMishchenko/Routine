import Combine
import CoreData
import Foundation

protocol RoutineStore {
  func allRoutines() async throws -> [Routine]
  func save(_ routine: Routine) async throws
  func update(_ routine: Routine) async throws
  func delete(_ routine: Routine) async throws
  func observeAll() -> AnyPublisher<[Routine], Error>
  func fillHistoryIfNeeded() async throws
}

final class CoreDataRoutineStore: RoutineStore {
  // MARK: - Dependencies
  private let coreDataStack: CoreDataStack
  
  // MARK: - Init
  init(coreDataStack: CoreDataStack) {
    self.coreDataStack = coreDataStack
  }
  
  // MARK: - Public
  func allRoutines() async throws -> [Routine] {
    try await withCheckedThrowingContinuation { continuation in
      allRoutines { continuation.resume(with: $0) }
    }
  }
  
  func save(_ routine: Routine) async throws {
    try await withCheckedThrowingContinuation { continuation in
      save(routine) { continuation.resume(with: $0) }
    }
  }
  
  func update(_ routine: Routine) async throws {
    try await withCheckedThrowingContinuation { continuation in
      update(routine, delete: false) { continuation.resume(with: $0) }
    }
  }
  
  func delete(_ routine: Routine) async throws {
    try await withCheckedThrowingContinuation { continuation in
      update(routine, delete: true) { continuation.resume(with: $0) }
    }
  }
  
  func observeAll() -> AnyPublisher<[Routine], Error> {
    CoreDataPublisher(
      request: NSFetchRequest<RoutineEntity>(entityName: String(describing: RoutineEntity.self)),
      context: coreDataStack.persistentContainer.viewContext
    )
    .map { $0.compactMap { $0.model } }
    .eraseToAnyPublisher()
  }
  
  func fillHistoryIfNeeded() async throws {
    try await withCheckedThrowingContinuation { continuation in
      fillHistoryIfNeeded { continuation.resume(with: $0) }
    }
  }

  // MARK: - Private
  private func allRoutines(completion: @escaping (Result<[Routine], Error>) -> Void) {
    coreDataStack.persistentContainer.performBackgroundTask {
      let request = NSFetchRequest<RoutineEntity>(entityName: String(describing: RoutineEntity.self))
      do {
        completion(.success(try $0.fetch(request).compactMap { $0.model }))
      } catch {
        completion(.failure(error))
      }
    }
  }

  private func save(_ routine: Routine, completion: @escaping (Result<Void, Error>) -> Void) {
    coreDataStack.persistentContainer.performBackgroundTask {
      _ = RoutineEntity(context: $0, routine: routine)

      do {
        try $0.saveIfNeeded()
        completion(.success(Void()))
      } catch {
        $0.rollback()
        completion(.failure(error))
      }
    }
  }
  
  private func update(_ routine: Routine, delete: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
    coreDataStack.persistentContainer.performBackgroundTask {
      let request = NSFetchRequest<RoutineEntity>(entityName: String(describing: RoutineEntity.self))
      request.predicate = NSPredicate(format: "uuid == %@", routine.uuid as CVarArg)
      
      do {
        guard let result = try $0.fetch(request).first else {
          completion(.success(Void()))
          return
        }
        
        $0.delete(result)
        
        if !delete {
          _ = RoutineEntity(context: $0, routine: routine)
        }
        try $0.saveIfNeeded()
        completion(.success(Void()))
      } catch {
        $0.rollback()
        completion(.failure(error))
      }
    }
  }
  
  // swiftlint:disable:next function_body_length
  private func fillHistoryIfNeeded(completion: @escaping (Result<Void, Error>) -> Void) {
    coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
      guard let self = self else { return }
      let request = NSFetchRequest<RoutineEntity>(entityName: String(describing: RoutineEntity.self))
      
      do {
        let routines = try context.fetch(request)
        routines.forEach { routine in
          guard
            let progress = routine.progress,
            let history = routine.history,
            let latestItem = history.sorted(by: { $0.date < $1.date }).last,
            !self.isDateInCurrentPeriod(latestItem.date, frequency: routine.frequencyType)
          else { return }
          
          var latestDate = latestItem.date
          
          while true {
            guard
              let nextDate = self.dateByAddingCurrentPeriod(to: latestDate, frequency: routine.frequencyType),
              let daysBetween = nextDate.daysBetween(Date()),
              daysBetween >= .zero
            else {
              break
            }
            
            routine.append(
              HistoryEntity(
                context: context,
                history: History(
                  uuid: UUID(),
                  date: nextDate,
                  goal: Int(progress.goal),
                  result: .zero
                )
              )
            )
            
            latestDate = nextDate
            
            if self.isDateInCurrentPeriod(latestDate, frequency: routine.frequencyType) { break }
          }
          
          progress.resetCurrent()
        }

        routines.forEach { routine in
          let groups = routine.history?.reduce(into: [Date: [HistoryEntity]]()) { result, item in
            guard let date = item.date.withoutTime else { return }
            let existing = result[date] ?? []
            result[date] = existing + [item]
          }
          
          let itemsToRemove = groups?
            .map { item -> [HistoryEntity] in
              guard item.value.count > 1 else { return [] }
              let itemToStay = item.value.max { $0.result < $1.result }
              return item.value.filter { $0.uuid != itemToStay?.uuid }
            }
            .flatMap { $0 }
          
          itemsToRemove?.forEach {
            routine.remove($0)
          }
        }

        try context.saveIfNeeded()
        completion(.success(Void()))
      } catch {
        context.rollback()
        completion(.failure(error))
      }
    }
  }
  
  private func isDateInCurrentPeriod(_ date: Date, frequency: Frequency) -> Bool {
    switch frequency {
    case .daily: return date.isInToday
    case .weekly: return date.isInThisWeek
    case .monthly: return date.isInThisMonth
    }
  }
  
  private func dateByAddingCurrentPeriod(to date: Date, frequency: Frequency) -> Date? {
    switch frequency {
    case .daily: return date.byAddingDay
    case .weekly: return date.byAddingWeek
    case .monthly: return date.byAddingMonth
    }
  }
}
