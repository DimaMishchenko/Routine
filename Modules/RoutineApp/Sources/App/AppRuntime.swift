import CloudKitSyncMonitor
import Foundation

@MainActor final class AppRuntime {
  static let shared = AppRuntime(prepareStorage: {
    if Environment.current != .local {
      _ = SyncMonitor.shared
    }
  }, makeServices: {
    try ServiceFactory(coreDataStack: CoreDataStackAssembly.routineStack())
  })

  private let makeServices: () throws -> ServiceFactory
  private let prepareStorage: () -> Void
  private var services: ServiceFactory?

  init(prepareStorage: @escaping () -> Void = {}, makeServices: @escaping () throws -> ServiceFactory) {
    self.prepareStorage = prepareStorage
    self.makeServices = makeServices
  }

  func serviceFactory() throws -> ServiceFactory {
    if let services { return services }
    prepareStorage()
    let created = try makeServices()
    services = created
    return created
  }
}
