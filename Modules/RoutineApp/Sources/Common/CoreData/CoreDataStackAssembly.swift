import Foundation

enum CoreDataStackAssembly {
  // MARK: - Constants
  private enum Constants {
    static let cloudKitContainerIdentifierProd = "iCloud.com.dm.routine.app.icloud.prod"
    static let cloudKitContainerIdentifierDev = "iCloud.com.dm.routine.app.icloud.dev"
  
    static let sharedGroupIdentifierProd = "group.com.dm.routine.app.shared.prod"
    static let sharedGroupIdentifierDev = "group.com.dm.routine.app.shared.dev"
    
    static let coreDataContainerName = "Routine"
  }
  
  // MARK: - Public
  static func routineStack() -> CoreDataStack {
    switch Environment.current {
    case .dev:
      return CoreDataStack(
        containerName: Constants.coreDataContainerName,
        sharedGroupIdentifier: Constants.sharedGroupIdentifierDev,
        cloudKitIdentifier: Constants.cloudKitContainerIdentifierDev
      )
    case .prod:
      return CoreDataStack(
        containerName: Constants.coreDataContainerName,
        sharedGroupIdentifier: Constants.sharedGroupIdentifierProd,
        cloudKitIdentifier: Constants.cloudKitContainerIdentifierProd
      )
    }
  }
}
