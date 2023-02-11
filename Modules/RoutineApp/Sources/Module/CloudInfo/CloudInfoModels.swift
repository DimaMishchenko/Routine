import Foundation

enum CloudInfo {
  struct StatusVM: Hashable, Equatable {
    let title: String
    var state: SyncState = .notStarted
  }
  
  enum SyncState: Hashable, Equatable {
    case notStarted
    case inProgress
    case success
    case failed
  }
}
