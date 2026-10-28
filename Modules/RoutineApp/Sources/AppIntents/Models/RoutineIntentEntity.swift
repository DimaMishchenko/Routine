import AppIntents
import Foundation

struct RoutineIntentEntity: AppEntity, Hashable, Equatable {
  static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "intent.routine.type")
  static let defaultQuery = RoutineIntentEntityQuery()
  
  var id: UUID { item.uuid }
  var displayRepresentation: DisplayRepresentation {
    .init(
      title: "\(item.name)",
      subtitle: {
        let progress = "\(item.progress.current)/\(item.progress.goal.rawValue)"
        return item.description.isEmpty ? "\(progress)" : "\(item.description) \(progress)"
      }(),
      image: item.emoji.image?.pngData().flatMap { .init(data: $0) }
    )
  }
  
  let item: Routine
  
  init(routine: Routine) {
    item = routine
  }
}

struct RoutineIntentEntityQuery: @unchecked Sendable, EntityStringQuery {
  func entities(for identifiers: [UUID]) async throws -> [RoutineIntentEntity] {
    let store = try await IntentRuntime.store()
    return try await store.allRoutines()
      .filter { identifiers.contains($0.uuid) }
      .map { .init(routine: $0) }
  }
  
  func suggestedEntities() async throws -> [RoutineIntentEntity] {
    let store = try await IntentRuntime.store()
    return try await store.allRoutines().map { .init(routine: $0) }
  }
  
  func entities(matching string: String) async throws -> [RoutineIntentEntity] {
    let store = try await IntentRuntime.store()
    return try await store.allRoutines()
      .filter {
        $0.name.lowercased().contains(string.lowercased()) ||
        $0.description.lowercased().contains(string.lowercased())
      }
      .map { .init(routine: $0) }
  }
}

struct RoutineOptionsProvider: DynamicOptionsProvider {
  func results() async throws -> ItemCollection<RoutineIntentEntity> {
    let store = try await IntentRuntime.store()
    let routines = try await store.allRoutines()
    let routinesByType = Dictionary(grouping: routines, by: \.frequency)
    
    return ItemCollection(
      sections: routinesByType
        .sorted { $0.key < $1.key }
        .map {
          ItemSection(
            title: .init(stringLiteral: $0.key.localized),
            items: $0.value
              .map { RoutineIntentEntity(routine: $0) }
              .map {
                IntentItem(
                  $0,
                  title: $0.displayRepresentation.title,
                  subtitle: $0.displayRepresentation.subtitle,
                  image: $0.displayRepresentation.image
                )
              }
          )
        }
    )
  }
}
