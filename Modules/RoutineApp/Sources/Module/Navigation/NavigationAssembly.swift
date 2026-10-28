import UIKit

final class NavigationAssembly {
  private let assemblyFactory: AssemblyFactory

  init(assemblyFactory: AssemblyFactory) {
    self.assemblyFactory = assemblyFactory
  }

  @MainActor func controller() -> UIViewController {
    let model = NavigationViewModelImpl()
    let root = RoutineNavigationController(rootViewController: assemblyFactory.routineList().controller())
    root.onAppear = { [weak root, assemblyFactory] in
      guard let root, root.presentedViewController == nil else { return }
      switch model.nextPresentation() {
      case .tutorial:
        let tutorial = assemblyFactory.tutorial().controller {
          model.completeTutorial()
          root.presentLaunchIfNeeded()
        }
        tutorial.isModalInPresentation = true
        root.present(tutorial, animated: true)
      case .freeAnnouncement:
        let announcement = FreeAnnouncementVC { [weak root] in
          root?.dismiss(animated: true) { model.completeAnnouncement() }
        }
        announcement.onAppear = { model.announcementDidAppear() }
        root.present(announcement, animated: true)
      case nil:
        break
      }
    }
    return root
  }
}

final class RoutineNavigationController: UINavigationController {
  var onAppear: (() -> Void)?

  private var contentAvailable = false

  func setContentAvailable(_ available: Bool) {
    contentAvailable = available
    presentLaunchIfNeeded()
  }

  func presentLaunchIfNeeded() {
    guard contentAvailable, isViewLoaded, view.window != nil else { return }
    onAppear?()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presentLaunchIfNeeded()
  }
}
