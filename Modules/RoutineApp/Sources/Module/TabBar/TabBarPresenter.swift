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
          title: RoutineAppStrings.Tabbar.Tab.routines,
          sfSymbol: .rCircle
        ),
        TabBar.ItemVM(
          type: .settings,
          title: RoutineAppStrings.Tabbar.Tab.settings,
          sfSymbol: .gear
        )
      ]
    )
  }
}
