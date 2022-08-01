import Combine
import CoreData
import Foundation

protocol RoutineStore {
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
  func save(_ routine: Routine) async throws {
    try await withCheckedThrowingContinuation { continuation in
      save(routine) {
        continuation.resume(with: $0)
      }
    }
  }
  
  func update(_ routine: Routine) async throws {
    try await withCheckedThrowingContinuation { continuation in
      update(routine, delete: false) {
        continuation.resume(with: $0)
      }
    }
  }
  
  func delete(_ routine: Routine) async throws {
    try await withCheckedThrowingContinuation { continuation in
      update(routine, delete: true) {
        continuation.resume(with: $0)
      }
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
  private func save(_ routine: Routine, completion: @escaping (Result<Void, Error>) -> Void) {
    coreDataStack.persistentContainer.performBackgroundTask {
      _ = RoutineEntity(context: $0, routine: routine)

      do {
        try $0.save()
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
        try $0.save()
        completion(.success(Void()))
      } catch {
        $0.rollback()
        completion(.failure(error))
      }
    }
  }
  
  private func fillHistoryIfNeeded(completion: @escaping (Result<Void, Error>) -> Void) {
    coreDataStack.persistentContainer.performBackgroundTask { context in
      let request = NSFetchRequest<RoutineEntity>(entityName: String(describing: RoutineEntity.self))
      
      do {
        let routines = try context.fetch(request)
        routines.forEach { routine in
          guard
            let progress = routine.progress,
            let history = routine.history,
            let latestItem = history.sorted(by: { $0.date < $1.date }).last,
            !latestItem.date.compareWithToday(to: .day)
          else { return }
          
          let today = Date()
          var latestDate = latestItem.date
          
          while true {
            guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: latestDate) else { break }
            
            routine.append(
              HistoryEntity(
                context: context,
                history: History(
                  uuid: UUID(),
                  date: nextDay,
                  goal: Int(progress.goal),
                  result: .zero
                )
              )
            )
            
            latestDate = nextDay
            
            if latestDate.compare(with: today, to: .day) { break }
          }
        }
        
        try context.save()
        completion(.success(Void()))
      } catch {
        context.rollback()
        completion(.failure(error))
      }
    }
  }
}
