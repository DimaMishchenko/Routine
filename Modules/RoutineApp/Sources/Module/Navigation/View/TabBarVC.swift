import UIKit

final class TabBarVC<VM: NavigationViewModel>: UITabBarController {
  // MARK: - Dependencies
  private let viewModel: VM
  private let controllersFactory: NavigationControllersFactory
  
  // MARK: - Init
  init(
    viewModel: VM,
    controllersFactory: NavigationControllersFactory
  ) {
    self.viewModel = viewModel
    self.controllersFactory = controllersFactory
    super.init(nibName: nil, bundle: nil)
    viewControllers = viewModel.items.map {
      let vc = controllersFactory.controller(for: $0.type)
      vc.tabBarItem = .init(title: $0.title, image: $0.image, selectedImage: $0.selectedImage)
      return vc
    }
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lazy Load
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.viewDidLoad()
  }
}
