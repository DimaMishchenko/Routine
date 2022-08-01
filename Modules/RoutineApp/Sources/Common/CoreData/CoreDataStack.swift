import CloudKit
import CoreData
import Foundation

final class CoreDataStack {
  // MARK: - Constants
  private enum Constants {
    static let storageFolderName = "Database"
    static let storageName = "RoutineApp.sqlite"
  }
  
  // MARK: - Properties
  let persistentContainer: NSPersistentCloudKitContainer
  
  // MARK: - Init
  init(containerName: String, sharedGroupIdentifier: String, cloudKitIdentifier: String) {
    persistentContainer = AppNSPersistentCloudKitContainer(name: containerName)
    
    guard let storageURL = sharedStorageURL(for: sharedGroupIdentifier) else {
      // TODO: - Handle error
      return
    }
    
    let localStorage = NSPersistentStoreDescription(url: storageURL)
    let localStorageOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKitIdentifier)
    localStorageOptions.databaseScope = .private
    localStorage.cloudKitContainerOptions = localStorageOptions
    persistentContainer.persistentStoreDescriptions = [localStorage]
    persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    
    persistentContainer.loadPersistentStores { _, error in
      // TODO: - Handle errors
      if let error = error {
        fatalError(error.localizedDescription)
      }
    }
  }
  
  // MARK: - Private
  private func sharedStorageURL(for identifier: String) -> URL? {
    guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
      return nil
    }
    
    return containerURL
      .appendingPathComponent(Constants.storageFolderName)
      .appendingPathComponent(Constants.storageName)
  }
}

private class AppNSPersistentCloudKitContainer: NSPersistentCloudKitContainer {
  override func newBackgroundContext() -> NSManagedObjectContext {
    let context = super.newBackgroundContext()
    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    
    return context
  }
  
  override func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
    super.performBackgroundTask { context in
      context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
      block(context)
    }
  }
}
