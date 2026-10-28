import Combine
import CoreData
@testable import Routine
import XCTest

final class PersistenceTests: XCTestCase {
  func testLocalStorageDoesNotEnableCloudKit() throws {
    let stack = try CoreDataStack(storage: .inMemory)
    XCTAssertNil(stack.persistentContainer.persistentStoreDescriptions.first?.cloudKitContainerOptions)
    XCTAssertEqual(stack.persistentContainer.persistentStoreDescriptions.first?.type, NSInMemoryStoreType)
  }

  func testUpdateKeepsManagedObjectIdentityAndHistoryMissingFromStaleEdit() async throws {
    let stack = try CoreDataStack(storage: .inMemory)
    let store = CoreDataRoutineStore(coreDataStack: stack)
    let original = routine()
    try await store.save(original)
    let before = try await objectIDs(in: stack)
    var edited = EditableRoutine(routine: original)
    edited.name = "Updated"
    edited.increaseProgress()
    edited.history = []
    try await store.update(edited.routine)
    let after = try await objectIDs(in: stack)
    XCTAssertEqual(before, after)
    let saved = try await store.allRoutines()
    XCTAssertEqual(saved.count, 1)
    XCTAssertEqual(saved.first?.name, "Updated")
    XCTAssertTrue(saved[0].history.contains { $0.uuid == original.history[0].uuid })
  }

  func testExplicitHistoryDeletionRemovesOnlyRequestedEntryFromRequestedRoutine() async throws {
    let stack = try CoreDataStack(storage: .inMemory)
    let store = CoreDataRoutineStore(coreDataStack: stack)
    var original = EditableRoutine(routine: routine())
    let removedID = original.history[0].uuid
    let kept = History(uuid: UUID(), date: Date(), goal: 5, result: 4)
    original.history.append(kept)
    let unrelated = routine()
    try await store.save(original.routine)
    try await store.save(unrelated)
    try await store.removeHistory(id: removedID, from: unrelated.uuid)
    var values = try await store.allRoutines()
    XCTAssertEqual(values.first(where: { $0.uuid == original.routine.uuid })?.history.count, 2)
    try await store.removeHistory(id: removedID, from: original.routine.uuid)
    try await store.removeHistory(id: removedID, from: original.routine.uuid)
    values = try await store.allRoutines()
    XCTAssertEqual(values.first(where: { $0.uuid == original.routine.uuid })?.history, [kept])
    XCTAssertEqual(values.first(where: { $0.uuid == unrelated.uuid }), unrelated)
    let context = stack.persistentContainer.newBackgroundContext()
    let count = try await context.performForTesting {
      try context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: "HistoryEntity"))
    }
    XCTAssertEqual(count, 2)
  }

  @MainActor func testCalendarDeselectionPersistsExplicitHistoryRemoval() async throws {
    let stack = try CoreDataStack(storage: .inMemory)
    let store = CoreDataRoutineStore(coreDataStack: stack)
    let yesterday = try XCTUnwrap(Calendar.app.date(byAdding: .day, value: -1, to: Date()))
    let original = routine(date: yesterday)
    try await store.save(original)
    let removed = expectation(description: "Calendar history removal saved")
    let observation = store.observeAll()
      .first(where: { $0.first?.history.isEmpty == true })
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in removed.fulfill() })
    let viewModel = RoutineDetailsViewModelImpl(routine: original, routineStore: store)
    viewModel.showAlert = { $0.handler(.yes) }
    viewModel.deselect(date: yesterday)
    await fulfillment(of: [removed], timeout: 2)
    withExtendedLifetime((viewModel, observation)) {}
  }

  func testDeletingRoutineRemovesItsGraph() async throws {
    let stack = try CoreDataStack(storage: .inMemory)
    let store = CoreDataRoutineStore(coreDataStack: stack)
    let value = routine()
    try await store.save(value)
    try await store.delete(value)
    let context = stack.persistentContainer.newBackgroundContext()
    try await context.performForTesting {
      for entity in ["RoutineEntity", "HistoryEntity", "ProgressEntity", "ReminderEntity"] {
        XCTAssertEqual(try context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: entity)), 0)
      }
    }
  }

  func testLegacySQLiteFixtureReopensWithoutChangingStoredValues() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let url = directory.appendingPathComponent("RoutineApp.sqlite")
    let model = try CoreDataStack(storage: .inMemory).persistentContainer.managedObjectModel
    let legacy = NSPersistentContainer(name: "Routine", managedObjectModel: model)
    let description = NSPersistentStoreDescription(url: url)
    description.shouldAddStoreAsynchronously = false
    legacy.persistentStoreDescriptions = [description]
    var error: Error?
    legacy.loadPersistentStores { _, failure in error = failure }
    if let error = error { throw error }
    let original = routine()
    try await legacy.viewContext.performForTesting {
      _ = RoutineEntity(context: legacy.viewContext, routine: original)
      try legacy.viewContext.save()
    }
    for store in legacy.persistentStoreCoordinator.persistentStores {
      try legacy.persistentStoreCoordinator.remove(store)
    }
    let revived = try CoreDataStack(storage: .local(url))
    let reopened = try await CoreDataRoutineStore(coreDataStack: revived).allRoutines()
    XCTAssertEqual(reopened, [original])
    XCTAssertNil(revived.persistentContainer.persistentStoreDescriptions.first?.cloudKitContainerOptions)
    for store in revived.persistentContainer.persistentStoreCoordinator.persistentStores {
      try revived.persistentContainer.persistentStoreCoordinator.remove(store)
    }
  }

  func testHistoryCatchupIsIdempotentAndPreservesPastResults() async throws {
    let stack = try CoreDataStack(storage: .inMemory)
    let store = CoreDataRoutineStore(coreDataStack: stack)
    let past = try XCTUnwrap(Calendar.app.date(byAdding: .day, value: -3, to: Date()))
    let original = routine(date: past)
    try await store.save(original)
    try await store.fillHistoryIfNeeded()
    let first = try await store.allRoutines()
    try await store.fillHistoryIfNeeded()
    let second = try await store.allRoutines()
    XCTAssertEqual(Set(first[0].history), Set(second[0].history))
    XCTAssertTrue(second[0].history.contains(original.history[0]))
    XCTAssertEqual(second[0].progress.current, 0)
    XCTAssertGreaterThan(second[0].history.count, original.history.count)
  }

  func testCatchupDoesNotDeleteSameDayHistoryFromImportedGraphs() async throws {
    let stack = try CoreDataStack(storage: .inMemory)
    let store = CoreDataRoutineStore(coreDataStack: stack)
    let original = routine()
    var edit = EditableRoutine(routine: original)
    edit.history.append(History(uuid: UUID(), date: original.history[0].date, goal: 5, result: 4))
    try await store.save(edit.routine)
    try await store.fillHistoryIfNeeded()
    let saved = try await store.allRoutines()
    XCTAssertEqual(Set(saved[0].history), Set(edit.history))
  }

  private func objectIDs(in stack: CoreDataStack) async throws -> Set<NSManagedObjectID> {
    let context = stack.persistentContainer.newBackgroundContext()
    return try await context.performForTesting {
      var result = Set<NSManagedObjectID>()
      for name in ["RoutineEntity", "ProgressEntity", "HistoryEntity", "ReminderEntity"] {
        let request = NSFetchRequest<NSManagedObject>(entityName: name)
        result.formUnion(try context.fetch(request).map(\.objectID))
      }
      return result
    }
  }

  private func routine(date: Date = Date()) -> Routine {
    Routine(
      uuid: UUID(),
      name: "Read",
      description: "Ten pages",
      emoji: "📚",
      startDate: date,
      frequency: .daily,
      progress: Progress(goal: 5, current: 2),
      remind: true,
      reminders: [Reminder(uuid: UUID(), type: .daily(.form(hours: 9, minutes: 30)))],
      history: [History(uuid: UUID(), date: date, goal: 5, result: 2)]
    )
  }
}

extension NSManagedObjectContext {
  fileprivate func performForTesting<Value>(_ operation: @escaping () throws -> Value) async throws -> Value {
    try await withCheckedThrowingContinuation { continuation in
      perform {
        do {
          continuation.resume(returning: try operation())
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
