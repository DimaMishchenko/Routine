import CloudKit
import CoreData
import Foundation

final class CoreDataCloudStack {
  // MARK: - Constants
  private enum Constants {
    static let storageFolderName = "Database"
    static let storageName = "RoutineApp.sqlite"
  }
  
  // MARK: - Properties
  let persistentContainer: NSPersistentCloudKitContainer
  
  // MARK: - Init
  init(containerName: String, sharedGroupIdentifier: String, cloudKitIdentifier: String) {
    persistentContainer = NSPersistentCloudKitContainer(name: containerName)
    
    guard let storageURL = sharedStorageURL(for: sharedGroupIdentifier) else {
      // TODO: - Handle error
      return
    }
    
    let localStorage = NSPersistentStoreDescription(url: storageURL)
    let localStorageOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKitIdentifier)
    localStorageOptions.databaseScope = .private
    localStorage.cloudKitContainerOptions = localStorageOptions
    persistentContainer.persistentStoreDescriptions = [localStorage]
    
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
