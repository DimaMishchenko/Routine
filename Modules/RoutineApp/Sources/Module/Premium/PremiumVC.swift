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
    Analytics.send(.deleteRoutine, parameters: [.subscribed: viewModel.isPremium])
    
    view.backgroundColor = Color.Background.default
    title = RoutineAppStrings.Localizable.Premium.title
    #if targetEnvironment(macCatalyst)
    navigationItem.leftBarButtonItems = [
      UIBarButtonItem(
        title: RoutineAppStrings.Localizable.Premium.Button.restore,
        style: .plain,
        target: self,
        action: #selector(restore)
      )
    ]
    #else
    navigationItem.leftBarButtonItems = [
      UIBarButtonItem(
        title: RoutineAppStrings.Localizable.Premium.Button.restore,
        style: .plain,
        target: self,
        action: #selector(restore)
      ),
      UIBarButtonItem(
        title: RoutineAppStrings.Localizable.Premium.Button.redeem,
        style: .plain,
        target: self,
        action: #selector(redeem)
      )
    ]
    #endif
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: RoutineAppStrings.Localizable.Premium.Button.done,
      style: .done,
      target: self,
      action: #selector(done)
    )
  }
  
  // MARK: - Actions
  @objc private func restore() {
    viewModel.restore()
  }
  
  @objc private func redeem() {
    viewModel.redeem()
  }
  
  @objc private func done() {
    viewModel.close()
  }
}
