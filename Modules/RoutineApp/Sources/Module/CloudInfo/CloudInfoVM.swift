import CloudKitSyncMonitor
import Combine
import Foundation
import UIKit.UIImage

@MainActor protocol CloudInfoViewModel: ObservableObject {
  var cloudStatusVM: CloudInfo.StatusVM { get }
  var importStatusVM: CloudInfo.StatusVM { get }
  var exportStatusVM: CloudInfo.StatusVM { get }
  var errorHint: String? { get }
}

final class CloudInfoViewModelImpl: CloudInfoViewModel {
  // MARK: - Properties
  private(set) var cloudStatusVM = CloudInfo.StatusVM(title: RoutineAppStrings.CloudInfo.Row.iCloudStatus)
  private(set) var importStatusVM = CloudInfo.StatusVM(title: RoutineAppStrings.CloudInfo.Row.importStatus)
  private(set) var exportStatusVM = CloudInfo.StatusVM(title: RoutineAppStrings.CloudInfo.Row.exportStatus)
  private(set) var errorHint: String?
  
  private var cancellables: Set<AnyCancellable> = []
  
  init() {
    SyncMonitor.shared.objectWillChange
      .sink { [weak self] in
        if SyncMonitor.shared.networkAvailable == false {
          self?.errorHint = RoutineAppStrings.CloudInfo.ErrorHint.noNetwork
        } else if SyncMonitor.shared.iCloudAccountStatus != .available {
          self?.errorHint = RoutineAppStrings.CloudInfo.ErrorHint.iCloudAccount
        } else if SyncMonitor.shared.syncError {
          self?.errorHint = RoutineAppStrings.CloudInfo.ErrorHint.syncError
          SyncMonitor.shared.lastError.flatMap { Logger.log($0) }
        } else {
          self?.errorHint = nil
        }
      }
      .store(in: &cancellables)
    
    observe(SyncMonitor.shared.$setupState.eraseToAnyPublisher()) { [weak self] in
      self?.cloudStatusVM.state = $0
    }
    
    observe(SyncMonitor.shared.$importState.eraseToAnyPublisher()) { [weak self] in
      self?.importStatusVM.state = $0
    }
    
    observe(SyncMonitor.shared.$exportState.eraseToAnyPublisher()) { [weak self] in
      self?.exportStatusVM.state = $0
    }
  }
  
  private func observe(
    _ publisher: AnyPublisher<SyncMonitor.SyncState, Never>,
    onNewState: @escaping (CloudInfo.SyncState) -> Void
  ) {
    publisher
      .sink { [weak self] in
        switch $0 {
        case .notStarted:
          onNewState(.notStarted)
        case .inProgress:
          onNewState(.inProgress)
        case .succeeded:
          onNewState(.success)
        case .failed(_, _, let error):
          onNewState(.failed)
          error.flatMap { Logger.log($0) }
        }
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)
  }
}
