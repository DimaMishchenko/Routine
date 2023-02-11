import SwiftUI

struct CloudInfoView<VM: CloudInfoViewModel>: View {
  // MARK: - Dependencies
  @ObservedObject private var viewModel: VM
  
  init(viewModel: VM) {
    self.viewModel = viewModel
  }
  
  // MARK: - Public
  var body: some View {
    List {
      Section {
        Label {
          Text(viewModel.cloudStatusVM.title)
        } icon: {
          StatusIcon(
            status: viewModel.cloudStatusVM.state,
            notStartedAsSucess: false
          )
        }
        
        if let hint = viewModel.errorHint {
          Label {
            Text(hint)
          } icon: {
            Image(systemName: "exclamationmark.circle")
              .foregroundColor(.red)
          }
        }
      }

      if viewModel.cloudStatusVM.state == .success {
        Section {
          Label {
            Text(viewModel.importStatusVM.title)
          } icon: {
            StatusIcon(
              status: viewModel.importStatusVM.state,
              notStartedAsSucess: true
            )
          }
          
          Label {
            Text(viewModel.exportStatusVM.title)
          } icon: {
            StatusIcon(
              status: viewModel.exportStatusVM.state,
              notStartedAsSucess: true
            )
          }
        }        
      }
    }
    .listStyle(.insetGrouped)
  }
  
  struct StatusIcon: View {
    let status: CloudInfo.SyncState
    let notStartedAsSucess: Bool
    
    var body: some View {
      switch status {
      case .notStarted:
        if notStartedAsSucess {
          Image(systemName: "checkmark.icloud")
            .foregroundColor(.green)
        } else {
          Image(systemName: "bolt.horizontal.icloud")
            .foregroundColor(.gray)
        }
      case .inProgress:
        ProgressView()
      case .success:
        Image(systemName: "checkmark.icloud")
          .foregroundColor(.green)
      case .failed:
        Image(systemName: "exclamationmark.icloud")
          .foregroundColor(.red)
      }
    }
  }
}

#if DEBUG
// MARK: - Preview
struct CloudInfoView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      CloudInfoView(viewModel: VMMock())
        .navigationTitle("Appearance")
    }
  }
  
  class VMMock: CloudInfoViewModel {
    let cloudStatusVM = CloudInfo.StatusVM(title: "iCloud status")
    let importStatusVM = CloudInfo.StatusVM(title: "Import status")
    let exportStatusVM = CloudInfo.StatusVM(title: "Export status")
    var errorHint: String?
  }
}
#endif
