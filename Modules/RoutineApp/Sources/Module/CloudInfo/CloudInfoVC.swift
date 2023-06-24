import SwiftUI
import UIKit

final class CloudInfoVC<VM: CloudInfoViewModel>: UIHostingController<CloudInfoView<VM>> {
  // MARK: - Dependencies
  private let viewModel: VM
  
  // MARK: - Init
  init(viewModel: VM) {
    self.viewModel = viewModel
    super.init(rootView: CloudInfoView(viewModel: viewModel))
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    title = RoutineAppStrings.Localizable.CloudInfo.title
  }
}
