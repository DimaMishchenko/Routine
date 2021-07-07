import UIKit

final class TabBarVC: UITabBarController {
  // MARK: - Dependencies
  private let presenter: TabBarPresenter
  private let controllersFactory: TabBarControllersFactory
  
  // MARK: - Init
  init(
    presenter: TabBarPresenter,
    controllersFactory: TabBarControllersFactory
  ) {
    self.presenter = presenter
    self.controllersFactory = controllersFactory
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupItems()
  }
  
  // MARK: - Private
  private func setupItems() {
    let items = presenter.itemViewModels()
    
    viewControllers = items.enumerated().map {
      let vc = controllersFactory.controller(for: $0.element.type)
      vc.tabBarItem = .init(
        title: $0.element.title,
        image: UIImage(systemSymbol: $0.element.sfSymbol),
        tag: $0.offset
      )
      return vc
    }
  }
}
