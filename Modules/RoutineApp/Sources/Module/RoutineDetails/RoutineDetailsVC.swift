import SwiftUI
import UIKit

final class RoutineDetailsVC<VM: RoutineDetailsViewModel>: UIHostingController<RoutineDetailsView<VM>> {
  // MARK: - Properties
  private let viewModel: VM
  
  // MARK: - Init
  init(viewModel: VM) {
    self.viewModel = viewModel
    super.init(rootView: RoutineDetailsView(viewModel: viewModel))
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }

  // MARK: - Actions
  @objc private func close() { viewModel.close() }
  @objc private func edit() { viewModel.edit() }
}

// MARK: - Private
extension RoutineDetailsVC {
  private func setupUI() {
    view.backgroundColor = Color.Background.default
    setupNavBar()
  }
  
  private func setupNavBar() {
    title = RoutineAppStrings.RoutineDetails.title
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: RoutineAppStrings.NavBar.close,
      style: .plain,
      target: self,
      action: #selector(close)
    )
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: RoutineAppStrings.NavBar.edit,
      style: .done,
      target: self,
      action: #selector(edit)
    )
  }
}
