import Foundation

protocol TabBarPresenter: AnyObject {}

final class TabBarPresenterImpl: TabBarPresenter {
  // MARK: - Dependencies
  weak var view: TabBarViewInterface? {
    didSet { setup() }
  }
  
  // MARK: - Private
  private func setup() {
    view?.setup(
      with: [
        TabBar.ItemVM(
          type: .routines,
          title: RoutineStrings.Tabbar.Tab.routines,
          sfSymbol: .star
        ),
        TabBar.ItemVM(
          type: .settings,
          title: RoutineStrings.Tabbar.Tab.settings,
          sfSymbol: .gear
        )
      ]
    )
  }
}
