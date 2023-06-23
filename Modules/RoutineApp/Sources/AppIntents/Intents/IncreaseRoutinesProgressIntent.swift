import AppIntents
import Foundation

@available(iOS 16.0, *)
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
  
  @AppDependency private var store: RoutineStore?
  
  init() {}
  
  init(routines: [Routine]) {
    self.$routines.wrappedValue = routines.map { .init(routine: $0) }
  }

  func perform() async throws -> some IntentResult {
    guard !routines.isEmpty else {
      return .result(value: [RoutineIntentEntity](), dialog: "intent.IRP.result.noItems")
    }
    guard let store else { throw IntentError.noDependencies }
    
    var updatedItems: [RoutineIntentEntity] = []
    
    for routine in routines {
      var editable = EditableRoutine(routine: routine.item)
      editable.increaseProgress()
      try await store.update(editable.routine)
      updatedItems.append(.init(routine: editable.routine))
    }

    Analytics.send(.intentComplete)
    return .result(value: updatedItems, dialog: "intent.IRP.result.success")
  }
}
