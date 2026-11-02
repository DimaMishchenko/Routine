import SwiftUI
import UIKit

final class AppearanceVC<VM: AppearanceViewModel>: UIHostingController<AppearanceView<VM>>, NavigationContentLayout {
  var navigationContentInset: CGFloat { 20 }
  private let viewModel: VM
  
  init(viewModel: VM) {
    self.viewModel = viewModel
    super.init(rootView: AppearanceView(viewModel: viewModel))
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = RoutineAppStrings.Localizable.Appearance.title
  }
}
