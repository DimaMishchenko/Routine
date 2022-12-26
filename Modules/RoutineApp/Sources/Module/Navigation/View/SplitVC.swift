import Combine
import SwiftUI
import UIKit

final class SplitVC<VM: NavigationViewModel>: UISplitViewController {
  // MARK: - Dependencies
  private let viewModel: VM
  private let controllersFactory: NavigationControllersFactory
  
  // MARK: - Properties
  private let menuVC: UIHostingController<MenuView<VM>>
  private var cancellables: Set<AnyCancellable> = []

  // MARK: - Init
  init(
    viewModel: VM,
    controllersFactory: NavigationControllersFactory
  ) {
    self.viewModel = viewModel
    self.controllersFactory = controllersFactory
    self.menuVC = .init(rootView: MenuView(viewModel: viewModel))
    super.init(style: .doubleColumn)
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lazy Load
  override func viewDidLoad() {
    super.viewDidLoad()
    menuVC.title = RoutineAppStrings.routine
    setViewController(menuVC, for: .primary)
    viewModel.selectedItem.flatMap {
      setViewController(controllersFactory.controller(for: $0.type), for: .secondary)
    }
    updateSecondaryVC(for: viewModel.selectedItem)
    
    viewModel.selectedItemPublisher
      .sink { [weak self] in self?.updateSecondaryVC(for: $0) }
      .store(in: &cancellables)

    viewModel.viewDidLoad()
  }
  
  // MARK: - Private
  private func updateSecondaryVC(for item: Navigation.ItemVM?) {
    item.flatMap {
      setViewController(controllersFactory.controller(for: $0.type), for: .secondary)
    }
  }
}
