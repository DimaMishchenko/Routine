import AppIntents
import Foundation

enum IntentDependenciesRegisterer {
  static func register(with serviceFactory: ServiceFactory) {
    if #available(iOS 16.0, *) {
      AppDependencyManager.shared.add(RoutineStore.self) { [weak serviceFactory] in
        serviceFactory?.routineStore()
      }
    }
  }
}
