import UIKit

final class RoutineListAssembly {
  // MARK: - Public
  func controller() -> UIViewController {
    let presenter = RoutineListPresenterImpl()
    let vc = RoutineListVC(presenter: presenter)
    presenter.view = vc
    return vc
  }
}
