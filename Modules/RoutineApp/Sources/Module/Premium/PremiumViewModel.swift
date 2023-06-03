import Foundation

@MainActor protocol PremiumViewModel: ObservableObject {
  var isPremium: Bool { get }
  var items: [Premium.Item] { get }
  var offers: [Premium.Offer] { get }
  func purchase(id: String)
  func restore()
  func close()
  func manage()
}

final class PremiumViewModelImpl: PremiumViewModel {
  // MARK: - Properties
  var dismiss: (() -> Void)?
  
  @Published var isPremium: Bool = false
  
  let items: [Premium.Item] = [
    .init(
      icon: RoutineAppAsset.Icon.premiumRoutines.image,
      title: RoutineAppStrings.Premium.Item.Unlimited.title,
      description: RoutineAppStrings.Premium.Item.Unlimited.description
    ),
    .init(
      icon: RoutineAppAsset.Icon.premiumSecurity.image,
      title: RoutineAppStrings.Premium.Item.Security.title,
      description: RoutineAppStrings.Premium.Item.Security.description
    ),
    .init(
      icon: RoutineAppAsset.Icon.premiumReminders.image,
      title: RoutineAppStrings.Premium.Item.Reminders.title,
      description: RoutineAppStrings.Premium.Item.Reminders.description
    ),
    .init(
      icon: RoutineAppAsset.Icon.premiumCreator.image,
      title: RoutineAppStrings.Premium.Item.Creators.title,
      description: RoutineAppStrings.Premium.Item.Creators.description
    )
  ]
  
  @Published var offers: [Premium.Offer] = []
  
  // MARK: - Dependencies
  private let purchases: InAppPurchases
  
  // MARK: - Init
  init(purchases: InAppPurchases) {
    self.purchases = purchases
    purchases.$subscribed.assign(to: &$isPremium)
    
    Task {
      do {
        let offers: [Premium.Offer] = try await purchases.offerings().compactMap { offering in
          guard let period = offering.period else { return nil }
          let trial: String? = {
            guard let trial = offering.trial else { return nil }
            return "\(trial.amount) \(localizedPeriod(trial.period)) \(RoutineAppStrings.Premium.Offer.freeTrial)"
          }()
          return Premium.Offer(
            id: offering.id,
            title: "\(RoutineAppStrings.Premium.Offer.subscribe) \(offering.price) / \(localizedPeriod(period))",
            trialDescription: trial
          )
        }
        await MainActor.run { self.offers = offers }
      } catch {
        // TODO: - handle error
        Logger.log(error)
      }
    }
  }
  
  func purchase(id: String) {
    Task {
      do {
        try await purchases.purchase(with: id)
      } catch {
        // TODO: - handle error
        Logger.log(error)
      }
    }
  }
  
  func restore() {
    Task {
      do {
        try await purchases.restore()
        // TODO: - Log/analytics
      } catch {
        // TODO: - handle error
        Logger.log(error)
      }
    }
  }
  
  func close() {
    dismiss?()
  }
  
  func manage() {
    Task {
      do {
        try await purchases.manage()
      } catch {
        // TODO: - handle error
        Logger.log(error)
      }
    }
  }
  
  // MARK: - Private
  private func localizedPeriod(_ period: InAppPurchases.Package.Period) -> String {
    switch period {
    case .day: return RoutineAppStrings.Premium.Period.day
    case .week: return RoutineAppStrings.Premium.Period.week
    case .month: return RoutineAppStrings.Premium.Period.month
    case .year: return RoutineAppStrings.Premium.Period.year
    }
  }
}
