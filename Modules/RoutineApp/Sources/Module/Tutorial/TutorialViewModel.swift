import Foundation

@MainActor protocol TutorialViewModel: ObservableObject {
  var welcomeVM: Tutorial.WelcomeVM { get }
  var featuresVM: Tutorial.FeaturesVM { get }
  func close()
}

final class TutorialViewModelImpl: TutorialViewModel {
  private let environment: Environment

  var onClose: (() -> Void)?
  lazy var welcomeVM = createWelcomVM()
  lazy var featuresVM = createFeaturesVM()

  init(environment: Environment = .current) {
    self.environment = environment
  }

  func close() { onClose?() }
  private func createWelcomVM() -> Tutorial.WelcomeVM {
    let title = RoutineAppStrings.Localizable.Tutorial.Welcome.titlePrefix + " " + RoutineAppStrings.Localizable.routine
    let routineRange = (title as NSString).range(of: RoutineAppStrings.Localizable.routine)

    let attributedString = NSMutableAttributedString(string: title)
    attributedString.addAttribute(.foregroundColor, value: Color.tint, range: routineRange)

    return Tutorial.WelcomeVM(
      icon: RoutineAppAsset.Icon.appIcon.image,
      title: attributedString,
      description: RoutineAppStrings.Localizable.Tutorial.Welcome.message,
      actionTitle: RoutineAppStrings.Localizable.Tutorial.Welcome.action
    )
  }

  private func createFeaturesVM() -> Tutorial.FeaturesVM {
    Tutorial.FeaturesVM(
      title: RoutineAppStrings.Localizable.Tutorial.Features.title,
      message: RoutineAppStrings.Localizable.Tutorial.Features.message,
      actionTitle: RoutineAppStrings.Localizable.Tutorial.Features.action,
      features: [
        .init(
          icon: RoutineAppAsset.Icon.tutorialCheckmark.image,
          title: RoutineAppStrings.Localizable.Tutorial.Features.Maintain.title,
          description: RoutineAppStrings.Localizable.Tutorial.Features.Maintain.message
        ),
        .init(
          icon: RoutineAppAsset.Icon.add.image,
          title: RoutineAppStrings.Localizable.Tutorial.Features.Unlimited.title,
          description: RoutineAppStrings.Localizable.Tutorial.Features.Unlimited.message
        ),
        .init(
          icon: RoutineAppAsset.Icon.notification.image,
          title: RoutineAppStrings.Localizable.Tutorial.Features.Reminders.title,
          description: RoutineAppStrings.Localizable.Tutorial.Features.Reminders.message
        ),
        .init(
          icon: RoutineAppAsset.Icon.tutorialChart.image,
          title: RoutineAppStrings.Localizable.Tutorial.Features.Overview.title,
          description: RoutineAppStrings.Localizable.Tutorial.Features.Overview.message
        ),
        .init(
          icon: RoutineAppAsset.Icon.faceID.image,
          title: RoutineAppStrings.Localizable.Tutorial.Features.Security.title,
          description: RoutineAppStrings.Localizable.Tutorial.Features.Security.message
        )
      ] + cloudFeatures()
    )
  }

  private func cloudFeatures() -> [Tutorial.FeatureVM] {
    guard environment != .local else { return [] }
    return [
      .init(
        icon: RoutineAppAsset.Icon.tutorialCloud.image,
        title: RoutineAppStrings.Localizable.Tutorial.Features.Icloud.title,
        description: RoutineAppStrings.Localizable.Tutorial.Features.Icloud.message
      )
    ]
  }
}
