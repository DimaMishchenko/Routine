import SwiftUI
import UIKit

final class PremiumVC<VM: PremiumViewModel>: UIHostingController<PremiumView<VM>> {
  // MARK: - Dependencies
  private let viewModel: VM
  
  // MARK: - Init
  init(viewModel: VM) {
    self.viewModel = viewModel
    super.init(rootView: PremiumView(viewModel: viewModel))
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Color.Background.default
    title = RoutineAppStrings.Premium.title
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: RoutineAppStrings.Premium.Button.restore,
      style: .done,
      target: self,
      action: #selector(restore)
    )
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: RoutineAppStrings.Premium.Button.done,
      style: .done,
      target: self,
      action: #selector(done)
    )
  }
  
  // MARK: - Actions
  @objc private func restore() {
    viewModel.restore()
  }
  
  @objc private func done() {
    viewModel.close()
  }
}
