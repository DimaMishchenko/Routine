import Foundation

enum CoreDataStackAssembly {
  static func routineStack() throws -> CoreDataStack {
    try CoreDataStack(storage: storage(for: Environment.current))
  }

  static func storage(for environment: Environment) throws -> CoreDataStack.Storage {
    switch environment {
    case .local:
      let directory = try FileManager.default.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
      return .local(directory.appendingPathComponent("Database/RoutineApp.sqlite"))
    case .dev:
      return try cloudStorage(
        group: "group.com.dm.routine.app.shared.dev",
        container: "iCloud.com.dm.routine.app.icloud.dev"
      )
    case .prod:
      return try cloudStorage(
        group: "group.com.dm.routine.app.shared.prod",
        container: "iCloud.com.dm.routine.app.icloud.prod"
      )
    }
  }

  private static func cloudStorage(group: String, container: String) throws -> CoreDataStack.Storage {
    guard let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) else {
      throw CocoaError(.fileNoSuchFile)
    }
    return .cloud(directory.appendingPathComponent("Database/RoutineApp.sqlite"), containerIdentifier: container)
  }
}
