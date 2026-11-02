import SwiftUI
import UIKit

final class RoutineDetailsVC<VM: RoutineDetailsViewModel>: UIHostingController<RoutineDetailsView<VM>> {
  private let viewModel: VM
  
  init(viewModel: VM) {
    self.viewModel = viewModel
    super.init(rootView: RoutineDetailsView(viewModel: viewModel))
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }

  @objc private func close() { viewModel.close() }
  @objc private func edit() { viewModel.edit() }
}

extension RoutineDetailsVC {
  private func setupUI() {
    view.backgroundColor = Color.Background.default
    setupNavBar()
  }
  
  private func setupNavBar() {
    title = RoutineAppStrings.Localizable.RoutineDetails.title
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "xmark"),
      style: .plain,
      target: self,
      action: #selector(close)
    )
    navigationItem.leftBarButtonItem?.accessibilityLabel = RoutineAppStrings.Localizable.NavBar.close
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "pencil"),
      style: .done,
      target: self,
      action: #selector(edit)
    )
    navigationItem.rightBarButtonItem?.accessibilityLabel = RoutineAppStrings.Localizable.NavBar.edit
  }
}
