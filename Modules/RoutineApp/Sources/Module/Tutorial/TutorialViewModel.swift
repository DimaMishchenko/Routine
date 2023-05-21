import Foundation

@MainActor protocol TutorialViewModel: ObservableObject {
  var welcomeVM: Tutorial.WelcomeVM { get }
  var featuresVM: Tutorial.FeaturesVM { get }
  func close()
}

final class TutorialViewModelImpl: TutorialViewModel {
  // MARK: - Public Properties
  var onClose: (() -> Void)?
  lazy var welcomeVM = createWelcomVM()
  lazy var featuresVM = createFeaturesVM()

  // MARK: - Public
  func close() { onClose?() }

  // MARK: - Private
  private func createWelcomVM() -> Tutorial.WelcomeVM {
    let title = RoutineAppStrings.Tutorial.Welcome.titlePrefix + " " + RoutineAppStrings.routine
    let routineRange = (title as NSString).range(of: RoutineAppStrings.routine)

    let attributedString = NSMutableAttributedString(string: title)
    attributedString.addAttribute(.foregroundColor, value: Color.tint, range: routineRange)

    return Tutorial.WelcomeVM(
      icon: RoutineAppAsset.Icon.appIcon.image,
      title: attributedString,
      description: RoutineAppStrings.Tutorial.Welcome.message,
      actionTitle: RoutineAppStrings.Tutorial.Welcome.action
    )
  }

  private func createFeaturesVM() -> Tutorial.FeaturesVM {
    Tutorial.FeaturesVM(
      title: RoutineAppStrings.Tutorial.Features.title,
      message: RoutineAppStrings.Tutorial.Features.message,
      actionTitle: RoutineAppStrings.Tutorial.Features.action,
      features: [
        .init(
          icon: RoutineAppAsset.Icon.tutorialCheckmark.image,
          title: RoutineAppStrings.Tutorial.Features.Maintain.title,
          description: RoutineAppStrings.Tutorial.Features.Maintain.message
        ),
        .init(
          icon: RoutineAppAsset.Icon.tutorialCloud.image,
          title: RoutineAppStrings.Tutorial.Features.Icloud.title,
          description: RoutineAppStrings.Tutorial.Features.Icloud.message
        ),
        .init(
          icon: RoutineAppAsset.Icon.tutorialChart.image,
          title: RoutineAppStrings.Tutorial.Features.Overview.title,
          description: RoutineAppStrings.Tutorial.Features.Overview.message
        )
      ]
    )
  }
}
