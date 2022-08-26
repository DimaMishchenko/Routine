import SwiftUI
import UIKit

protocol AppearanceViewInterface: AnyObject {}

final class AppearanceVC<VM: AppearanceViewModel>: UIHostingController<AppearanceView<VM>> {
  // MARK: - Dependencies
  private let viewModel: VM
  
  // MARK: - Init
  init(viewModel: VM) {
    self.viewModel = viewModel
    super.init(rootView: AppearanceView(viewModel: viewModel))
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = RoutineAppStrings.Appearance.title
  }
}

// MARK: - AppearanceViewInterface
extension AppearanceVC: AppearanceViewInterface {}
