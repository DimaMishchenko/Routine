import Foundation

@MainActor protocol AppearanceViewModel: ObservableObject {
  var theme: Theme { get set }
}

final class AppearanceViewModelImpl: AppearanceViewModel {
  @Published var theme: Theme = Theme.current {
    didSet { Theme.current = theme }
  }
  
  // MARK: - AppearanceViewModel
}
