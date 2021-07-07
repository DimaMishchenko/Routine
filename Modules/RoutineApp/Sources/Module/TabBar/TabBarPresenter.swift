import Foundation

protocol TabBarPresenter {
  func itemViewModels() -> [TabBar.ItemVM]
}

final class TabBarPresenterImpl: TabBarPresenter {
  // MARK: - Public
  func itemViewModels() -> [TabBar.ItemVM] {
    [
      TabBar.ItemVM(
        type: .routines,
        title: "Routines",
        sfSymbol: .star
      ),
      TabBar.ItemVM(
        type: .settings,
        title: "Settings",
        sfSymbol: .gear
      )
    ]
  }
}
