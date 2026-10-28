@testable import Routine
import XCTest

final class AppRuntimeTests: XCTestCase {
  @MainActor func testRuntimeDefersOpeningStorageAndSharesTheSuccessfulFactory() throws {
    var openings = 0
    let runtime = AppRuntime {
      openings += 1
      return try ServiceFactory(coreDataStack: CoreDataStack(storage: .inMemory))
    }
    XCTAssertEqual(openings, 0)
    let first = try runtime.serviceFactory()
    let second = try runtime.serviceFactory()
    XCTAssertTrue(first === second)
    XCTAssertEqual(openings, 1)
  }

  @MainActor func testIntentQueryResolvesBeforeAnySceneIsConstructed() async throws {
    var openings = 0
    let runtime = AppRuntime {
      openings += 1
      return try ServiceFactory(coreDataStack: CoreDataStack(storage: .inMemory))
    }
    IntentRuntime.configure(runtime: runtime)
    defer { IntentRuntime.configure() }
    XCTAssertEqual(openings, 0)
    let entities = try await RoutineIntentEntityQuery().suggestedEntities()
    XCTAssertTrue(entities.isEmpty)
    XCTAssertEqual(openings, 1)
  }

  @MainActor func testShortcutParametersCannotOverwriteNewerRoutineFieldsOrProgress() async throws {
    let stack = try CoreDataStack(storage: .inMemory)
    let services = ServiceFactory(coreDataStack: stack)
    IntentRuntime.configure(runtime: AppRuntime { services })
    defer { IntentRuntime.configure() }
    var stale = EditableRoutine(routine: .new)
    stale.name = "Old name"
    let parameter = stale.routine
    var current = EditableRoutine(routine: parameter)
    current.name = "Current name"
    current.description = "Current description"
    current.remind = true
    current.reminders = [Reminder(uuid: UUID(), type: .daily(.form(hours: 11, minutes: 45)))]
    current.progress = Progress(goal: 5, current: 3)
    try await services.routineStore().save(current.routine)

    _ = try await IncreaseRoutinesProgressIntent(routines: [parameter]).perform()
    let afterIncrease = try await services.routineStore().allRoutines()
    var saved = try XCTUnwrap(afterIncrease.first)
    XCTAssertEqual(saved.progress.current, 4)
    XCTAssertEqual(saved.name, current.name)
    XCTAssertEqual(saved.description, current.description)
    XCTAssertEqual(saved.reminders, current.reminders)
    XCTAssertEqual(saved.remind, current.remind)

    _ = try await CompleteRoutinesIntent(routines: [parameter]).perform()
    let afterComplete = try await services.routineStore().allRoutines()
    saved = try XCTUnwrap(afterComplete.first)
    XCTAssertEqual(saved.progress.current, 5)
    XCTAssertEqual(saved.progress.goal.rawValue, 5)
    XCTAssertEqual(saved.name, current.name)
    XCTAssertEqual(saved.reminders, current.reminders)
  }

  @MainActor func testFailedOpeningCanRetryWithoutCachingOrReplacingStorage() throws {
    var openings = 0
    let runtime = AppRuntime {
      openings += 1
      if openings == 1 { throw CocoaError(.fileReadUnknown) }
      return try ServiceFactory(coreDataStack: CoreDataStack(storage: .inMemory))
    }
    XCTAssertThrowsError(try runtime.serviceFactory())
    _ = try runtime.serviceFactory()
    XCTAssertEqual(openings, 2)
  }
}
