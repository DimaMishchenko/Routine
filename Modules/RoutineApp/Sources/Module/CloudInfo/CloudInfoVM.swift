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
  private(set) var cloudStatusVM = CloudInfo.StatusVM(title: RoutineAppStrings.Localizable.CloudInfo.Row.iCloudStatus)
  private(set) var importStatusVM = CloudInfo.StatusVM(title: RoutineAppStrings.Localizable.CloudInfo.Row.importStatus)
  private(set) var exportStatusVM = CloudInfo.StatusVM(title: RoutineAppStrings.Localizable.CloudInfo.Row.exportStatus)
  @Published private(set) var errorHint: String?
  
  private var cancellables: Set<AnyCancellable> = []
  
  init(monitor: SyncMonitor = .shared) {
    updateErrorHint(monitor: monitor)
    monitor.objectWillChange
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        self?.updateErrorHint(monitor: monitor)
      }
      .store(in: &cancellables)
    
    observe(monitor.$setupState.eraseToAnyPublisher()) { [weak self] in
      self?.cloudStatusVM.state = $0
    }
    
    observe(monitor.$importState.eraseToAnyPublisher()) { [weak self] in
      self?.importStatusVM.state = $0
    }
    
    observe(monitor.$exportState.eraseToAnyPublisher()) { [weak self] in
      self?.exportStatusVM.state = $0
    }
  }

  private func updateErrorHint(monitor: SyncMonitor) {
    if monitor.networkAvailable == false {
      errorHint = RoutineAppStrings.Localizable.CloudInfo.ErrorHint.noNetwork
    } else if monitor.iCloudAccountStatus != .available {
      errorHint = RoutineAppStrings.Localizable.CloudInfo.ErrorHint.iCloudAccount
    } else if monitor.syncError {
      errorHint = RoutineAppStrings.Localizable.CloudInfo.ErrorHint.syncError
      monitor.lastError.flatMap { Logger.log($0) }
    } else {
      errorHint = nil
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
