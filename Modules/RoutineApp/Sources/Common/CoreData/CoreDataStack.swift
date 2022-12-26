import CloudKit
import CoreData
import Foundation

final class CoreDataStack {
  // MARK: - Constants
  private enum Constants {
    static let storageFolderName = "Database"
    static let storageName = "RoutineApp.sqlite"
    
    static let transactionAuthor = "RoutineApp.author"
  }
  
  // MARK: - Properties
  let persistentContainer: NSPersistentCloudKitContainer
  private lazy var historyQueue = with(OperationQueue()) { $0.maxConcurrentOperationCount = 1 }
  
  // MARK: - Init
  init(containerName: String, sharedGroupIdentifier: String, cloudKitIdentifier: String) {
    persistentContainer = with(AppNSPersistentCloudKitContainer(name: containerName)) {
      $0.transactionsAuthor = Constants.transactionAuthor
    }
    
    guard let storageURL = sharedStorageURL(for: sharedGroupIdentifier) else {
      Logger.log(.error, "Failed to create DB URL")
      fatalError("Failed to create DB URL")
    }
    
    Logger.log(.debug, "Storage path \(storageURL.absoluteString)")
    
    let localStorage = NSPersistentStoreDescription(url: storageURL)
    localStorage.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    localStorage.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

    let localStorageOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKitIdentifier)
    localStorageOptions.setValue(CKDatabase.Scope.private.rawValue, forKey: "databaseScope")
    localStorage.cloudKitContainerOptions = localStorageOptions
    persistentContainer.persistentStoreDescriptions = [localStorage]
    persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    
    persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    persistentContainer.viewContext.transactionAuthor = Constants.transactionAuthor

    persistentContainer.loadPersistentStores { _, error in
      if let error = error {
        Logger.log(error)
        fatalError(error.localizedDescription)
      }
    }
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(storeRemoteChange(_:)),
      name: .NSPersistentStoreRemoteChange,
      object: persistentContainer.persistentStoreCoordinator
    )
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
  
  @objc private func storeRemoteChange(_ notification: Notification) {
    guard
      let id = notification.userInfo?[NSStoreUUIDKey] as? String,
      let store = persistentContainer.persistentStoreCoordinator.persistentStores.first(where: { $0.identifier == id })
    else { return }

    historyQueue.addOperation { [weak self] in
      guard let self = self else { return }
      let context = self.persistentContainer.newBackgroundContext()
      context.performAndWait {
        let lastHistoryToken = self.historyToken(with: id)
        let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
        NSPersistentHistoryTransaction.fetchRequest.flatMap {
          $0.predicate = NSPredicate(format: "author != %@", Constants.transactionAuthor)
          request.fetchRequest = $0
        }
        request.affectedStores = [store]
        
        guard
          let result = try? context.execute(request) as? NSPersistentHistoryResult,
          let transactions = result.result as? [NSPersistentHistoryTransaction]
        else { return }
        
        if let newToken = transactions.last?.token {
          self.updateHistoryToken(with: id, token: newToken)
        }
        
        let changes = transactions
          .compactMap { $0.changes }
          .flatMap { $0 }
          .filter { $0.changedObjectID.entity.name == RoutineEntity.entity().name && $0.changeType == .insert }
        
        changes.forEach {
          guard let routine = context.object(with: $0.changedObjectID) as? RoutineEntity else { return }
          guard routine.value(forKey: "uuid") != nil else { return }

          let request = with(NSFetchRequest<RoutineEntity>(entityName: String(describing: RoutineEntity.self))) {
            $0.sortDescriptors = [NSSortDescriptor(key: "lastUpdateDate", ascending: false)]
            $0.predicate = NSPredicate(format: "uuid == %@", routine.uuid as CVarArg)
          }
          
          guard var duplicatedItems = try? context.fetch(request), duplicatedItems.count > 1 else { return }
          duplicatedItems.removeFirst()
          duplicatedItems.forEach { context.delete($0) }
        }
        
        do {
          try context.saveIfNeeded()
        } catch {
          Logger.log(error)
        }
      }
    }
  }
  
  private func historyToken(with id: String) -> NSPersistentHistoryToken? {
    Defaults<HistoryToken?>(key: .historyTokenKey(for: id)).wrappedValue?.token
  }
  
  private func updateHistoryToken(with id: String, token: NSPersistentHistoryToken) {
    var defaults = Defaults<HistoryToken?>(key: .historyTokenKey(for: id))
    defaults.wrappedValue = HistoryToken(token: token)
  }
}

private class AppNSPersistentCloudKitContainer: NSPersistentCloudKitContainer {
  // MARK: - Properties
  var transactionsAuthor: String?
  
  // MARK: - Overrides
  override func newBackgroundContext() -> NSManagedObjectContext {
    let context = super.newBackgroundContext()
    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

    return context
  }
  
  override func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
    super.performBackgroundTask { [transactionsAuthor] context in
      context.transactionAuthor = transactionsAuthor
      context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
      block(context)
    }
  }
}

// MARK: - DefaultsKey + HistoryTokenKey
extension DefaultsKey {
  fileprivate static func historyTokenKey(for id: String) -> DefaultsKey {
    .init(rawValue: "historyToken-\(id)")
  }
}
