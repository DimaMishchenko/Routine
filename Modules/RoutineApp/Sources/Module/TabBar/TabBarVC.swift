import UIKit

protocol TabBarViewInterface: AnyObject {
  func setup(with items: [TabBar.ItemVM])
}

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
}

// MARK: - TabBarViewInterface
extension TabBarVC: TabBarViewInterface {
  func setup(with items: [TabBar.ItemVM]) {
    viewControllers = items.map {
      let vc = controllersFactory.controller(for: $0.type)
      vc.tabBarItem = .init(
        title: $0.title,
        image: image(for: $0.type, selected: false),
        selectedImage: image(for: $0.type, selected: true)
      )
      return vc
    }
  }
}

// MARK: - Private
extension TabBarVC {
  private func image(for type: TabBar.ItemType, selected: Bool) -> UIImage {
    switch type {
    case .home:
      return selected ? RoutineAppAsset.Icon.homeSelected.image : RoutineAppAsset.Icon.home.image
    case .settings:
      return selected ? RoutineAppAsset.Icon.settingsSelected.image : RoutineAppAsset.Icon.settings.image
    }
  }
}
