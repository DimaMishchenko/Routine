import CoreData
import Foundation

final class CoreDataStack {
  private static let model: NSManagedObjectModel? = {
    guard let url = Bundle.module.url(forResource: "Routine", withExtension: "momd") else { return nil }
    return NSManagedObjectModel(contentsOf: url)
  }()

  enum Storage {
    case local(URL)
    case cloud(URL, containerIdentifier: String)
    case inMemory
  }

  let persistentContainer: NSPersistentCloudKitContainer

  init(storage: Storage) throws {
    guard let model = Self.model else { throw CocoaError(.fileReadCorruptFile) }
    persistentContainer = AppNSPersistentCloudKitContainer(name: "Routine", managedObjectModel: model)
    let description: NSPersistentStoreDescription
    switch storage {
    case .inMemory:
      description = NSPersistentStoreDescription()
      description.type = NSInMemoryStoreType
    case .local(let url):
      try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
      description = NSPersistentStoreDescription(url: url)
    case let .cloud(url, identifier):
      try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
      description = NSPersistentStoreDescription(url: url)
      description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: identifier)
      description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
      description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
    }
    description.shouldAddStoreAsynchronously = false
    description.shouldMigrateStoreAutomatically = true
    description.shouldInferMappingModelAutomatically = true
    persistentContainer.persistentStoreDescriptions = [description]
    var loadingError: Error?
    persistentContainer.loadPersistentStores { _, error in loadingError = error }
    if let loadingError = loadingError { throw loadingError }
    persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    persistentContainer.viewContext.transactionAuthor = "RoutineApp.author"
  }
}

private final class AppNSPersistentCloudKitContainer: NSPersistentCloudKitContainer, @unchecked Sendable {
  override func newBackgroundContext() -> NSManagedObjectContext {
    let context = super.newBackgroundContext()
    context.transactionAuthor = "RoutineApp.author"
    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    return context
  }

  override func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
    super.performBackgroundTask { context in
      context.transactionAuthor = "RoutineApp.author"
      context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
      block(context)
    }
  }
}
