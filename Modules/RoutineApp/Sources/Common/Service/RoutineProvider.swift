import Combine
import CoreData
import Foundation

protocol RoutineProvider {
  func save(_ routine: Routine) async throws
  func update(_ routine: Routine) async throws
  func delete(_ routine: Routine) async throws
  func observeAll() -> AnyPublisher<[Routine], Error>
}

final class CoreDataRoutineProvider: RoutineProvider {
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
    .map { $0.map { $0.model } }
    .eraseToAnyPublisher()
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
        
        if delete {
          $0.delete(result)
        } else {
          result.apply(routine)
        }
        try $0.save()
        completion(.success(Void()))
      } catch {
        $0.rollback()
        completion(.failure(error))
      }
    }
  }
}
