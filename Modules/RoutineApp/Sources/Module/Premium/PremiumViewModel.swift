import Foundation

@MainActor protocol PremiumViewModel: ObservableObject {
  var isPremium: Bool { get }
  var items: [Premium.Item] { get }
  var offers: [Premium.Offer] { get }
  func purchase(id: String)
  func restore()
  func close()
  func manage()
  func redeem()
  func openTermsOfUse()
  func openPrivacyPolicy()
}

final class PremiumViewModelImpl: PremiumViewModel {
  // MARK: - Properties
  var dismiss: (() -> Void)?
  var openLinkInSafari: ((URL) -> Void)?
  
  @Published var isPremium = false
  
  let items: [Premium.Item] = [
    .init(
      icon: RoutineAppAsset.Icon.premiumRoutines.image,
      title: RoutineAppStrings.Localizable.Premium.Item.Unlimited.title,
      description: RoutineAppStrings.Localizable.Premium.Item.Unlimited.description
    ),
    .init(
      icon: RoutineAppAsset.Icon.premiumSecurity.image,
      title: RoutineAppStrings.Localizable.Premium.Item.Security.title,
      description: RoutineAppStrings.Localizable.Premium.Item.Security.description
    ),
    .init(
      icon: RoutineAppAsset.Icon.premiumReminders.image,
      title: RoutineAppStrings.Localizable.Premium.Item.Reminders.title,
      description: RoutineAppStrings.Localizable.Premium.Item.Reminders.description
    ),
    .init(
      icon: RoutineAppAsset.Icon.premiumCreator.image,
      title: RoutineAppStrings.Localizable.Premium.Item.Creators.title,
      description: RoutineAppStrings.Localizable.Premium.Item.Creators.description
    )
  ]
  
  @Published var offers: [Premium.Offer] = []
  
  // MARK: - Dependencies
  private let purchases: InAppPurchases
  
  // MARK: - Init
  init(purchases: InAppPurchases) {
    self.purchases = purchases
    purchases.$subscribed.assign(to: &$isPremium)
    
    Task(logError: true) {
      let offers: [Premium.Offer] = try await purchases.offerings().compactMap { offering in
        guard let period = offering.period else { return nil }
        let trial: String? = {
          guard let trial = offering.trial else { return nil }
          // swiftlint:disable:next line_length
          return "\(trial.amount) \(localizedPeriod(trial.period)) \(RoutineAppStrings.Localizable.Premium.Offer.freeTrial)"
        }()
        return Premium.Offer(
          id: offering.id,
          // swiftlint:disable:next line_length
          title: "\(RoutineAppStrings.Localizable.Premium.Offer.subscribe) \(offering.price) / \(localizedPeriod(period))",
          trialDescription: trial
        )
      }
      await MainActor.run { self.offers = offers }
    }
  }
  
  func purchase(id: String) {
    Task(logError: true) {
      try await purchases.purchase(with: id)
    }
  }
  
  func restore() {
    Task(logError: true) {
      let items = try await purchases.restore()
      items.forEach {
        Analytics.send(.restorePurchases, parameters: [.subscribed: isPremium, .purchaseId: $0])        
      }
    }
  }
  
  func redeem() {
    purchases.redeemCode()
  }
  
  func close() {
    dismiss?()
  }
  
  func manage() {
    Task(logError: true) {
      try await purchases.manage()
    }
  }
  
  func openTermsOfUse() {
    guard let url = Flag.termsOfUseLink else { return }
    Analytics.send(.termsOfUse)
    openLinkInSafari?(url)
  }

  func openPrivacyPolicy() {
    guard let url = Flag.privacyPolicyLink else { return }
    Analytics.send(.privacyPolicy)
    openLinkInSafari?(url)
  }
  
  // MARK: - Private
  private func localizedPeriod(_ period: InAppPurchases.Package.Period) -> String {
    switch period {
    case .day: return RoutineAppStrings.Localizable.Premium.Period.day
    case .week: return RoutineAppStrings.Localizable.Premium.Period.week
    case .month: return RoutineAppStrings.Localizable.Premium.Period.month
    case .year: return RoutineAppStrings.Localizable.Premium.Period.year
    }
  }
}
