import Foundation

@MainActor protocol NavigationViewModel: ObservableObject {
  var items: [Navigation.ItemVM] { get }
  var selectedItem: Navigation.ItemVM? { get set }
  var selectedItemPublisher: Published<Navigation.ItemVM?>.Publisher { get }
  func viewDidLoad()
}

final class NavigationViewModelImpl: NavigationViewModel {
  // MARK: - MenuViewModel
  var items: [Navigation.ItemVM] = [
    Navigation.ItemVM(
      type: .home,
      title: RoutineAppStrings.Tabbar.Tab.routines,
      image: RoutineAppAsset.Icon.home.image,
      selectedImage: RoutineAppAsset.Icon.homeSelected.image
    ),
    Navigation.ItemVM(
      type: .settings,
      title: RoutineAppStrings.Tabbar.Tab.settings,
      image: RoutineAppAsset.Icon.settings.image,
      selectedImage: RoutineAppAsset.Icon.settingsSelected.image
    )
  ]

  @Published var selectedItem: Navigation.ItemVM?
  var selectedItemPublisher: Published<Navigation.ItemVM?>.Publisher { $selectedItem }

  var showTutorial: (() -> Void)?
  @Defaults(key: .firstLaunch, initial: true) private var firstLaunch: Bool

  init() {
    selectedItem = items.first
  }

  func viewDidLoad() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      if self.firstLaunch {
        self.firstLaunch = false
        self.showTutorial?()
      }
    }
  }
}

extension DefaultsKey {
  static let firstLaunch: DefaultsKey = "first.launch"
}
