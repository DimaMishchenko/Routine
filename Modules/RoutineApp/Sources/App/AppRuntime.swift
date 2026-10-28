import Foundation

@MainActor final class AppRuntime {
  static let shared = AppRuntime {
    try ServiceFactory(coreDataStack: CoreDataStackAssembly.routineStack())
  }

  private let makeServices: () throws -> ServiceFactory
  private var services: ServiceFactory?

  init(makeServices: @escaping () throws -> ServiceFactory) {
    self.makeServices = makeServices
  }

  func serviceFactory() throws -> ServiceFactory {
    if let services { return services }
    let created = try makeServices()
    services = created
    return created
  }
}
