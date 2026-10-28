import AppIntents
import Foundation

struct IncreaseRoutinesProgressIntent: AppIntent, @unchecked Sendable {
  static let title: LocalizedStringResource = "intent.IRP.title"
  static let description = IntentDescription(
    "intent.IRP.description",
    categoryName: "intent.category.tracking"
  )
  static let openAppWhenRun = false
  static var parameterSummary: some ParameterSummary { Summary("intent.IRP.summaryPrefix \(\.$routines)") }
  
  @Parameter(
    title: "intent.parameter.routines.title",
    description: "intent.parameter.routines.description",
    optionsProvider: RoutineOptionsProvider()
  )
  private(set) var routines: [RoutineIntentEntity]

  init() {}
  
  init(routines: [Routine]) {
    self.$routines.wrappedValue = routines.map { .init(routine: $0) }
  }

  func perform() async throws -> some IntentResult {
    guard !routines.isEmpty else {
      return .result(value: [RoutineIntentEntity](), dialog: "intent.IRP.result.noItems")
    }
    let store = try await IntentRuntime.store()
    try await store.fillHistoryIfNeeded()
    let requestedIDs = Set(routines.map(\.id))
    let currentRoutines = try await store.allRoutines().filter { requestedIDs.contains($0.uuid) }
    guard !currentRoutines.isEmpty else {
      return .result(value: [RoutineIntentEntity](), dialog: "intent.IRP.result.noItems")
    }
    
    var updatedItems: [RoutineIntentEntity] = []
    
    for routine in currentRoutines {
      var editable = EditableRoutine(routine: routine)
      editable.increaseProgress()
      try await store.update(editable.routine)
      updatedItems.append(.init(routine: editable.routine))
    }

    return .result(value: updatedItems, dialog: "intent.IRP.result.success")
  }
}
