import Foundation

@MainActor protocol AppearanceViewModel: ObservableObject {
  var theme: Theme { get set }
  var confettiEnabled: Bool { get set }
}

final class AppearanceViewModelImpl: AppearanceViewModel {
  @Published var theme = Theme.current {
    didSet { Theme.current = theme }
  }

  @Published var confettiEnabled = Confetti.isEnabled {
    didSet { Confetti.isEnabled = confettiEnabled }
  }
}
