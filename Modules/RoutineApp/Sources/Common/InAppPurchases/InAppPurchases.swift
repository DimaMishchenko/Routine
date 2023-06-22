import Combine
import Foundation
import RevenueCat

final class InAppPurchases: NSObject {
  // MARK: - Constants
  private enum Constants {
    static let apiKey = (ProcessInfo.processInfo.environment["REVENUECAT_API_KEY"] ?? "")
  }
  
  // MARK: - Models
  struct Package {
    let id: String
    let price: String
    let period: Period?
    let trial: Trial?
    
    struct Trial {
      let amount: Int
      let period: Period
    }
    
    enum Period {
      case day
      case week
      case month
      case year
      
      fileprivate init(unit: SubscriptionPeriod.Unit) {
        switch unit {
        case .day: self = .day
        case .week: self = .week
        case .month: self = .month
        case .year: self = .year
        }
      }
    }
  }
  
  enum Errors: Error {
    case failedToGetCurrentOffering
    case noPackageForId
  }
  
  // MARK: - Properties
  @Published var subscribed = false
  
  // MARK: - Public
  func setup() {
    Purchases.logLevel = .debug
    Purchases.configure(withAPIKey: Constants.apiKey, appUserID: UserIdentifier.current)
    Purchases.shared.delegate = self
  }
  
  func offerings() async throws -> [Package] {
    try await currentOffering().availablePackages.map { package in
      Package(
        id: package.id,
        price: package.localizedPriceString,
        period: {
          guard let unit = package.storeProduct.subscriptionPeriod?.unit else { return nil }
          return .init(unit: unit)
        }(),
        trial: {
          guard
            let value = package.storeProduct.introductoryDiscount?.subscriptionPeriod.value,
            let unit = package.storeProduct.introductoryDiscount?.subscriptionPeriod.unit
          else { return nil }
          return .init(amount: value, period: .init(unit: unit))
        }()
      )
    }
  }
  
  func purchase(with id: String) async throws {
    guard let package = try await currentOffering().availablePackages.first(where: { $0.identifier == id }) else {
      throw Errors.noPackageForId
    }
    
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      Purchases.shared.purchase(package: package) { transaction, info, error, cancelled in
        continuation.resume()
        // TODO: - details + analytics
      }
    }
  }
  
  func restore() async throws -> [String] {
    try await .init(Purchases.shared.restorePurchases().activeSubscriptions)
  }
  
  func manage() async throws {
    try await Purchases.shared.showManageSubscriptions()
  }
  
  func redeemCode() {
    #if !targetEnvironment(macCatalyst)
      Purchases.shared.presentCodeRedemptionSheet()
    #endif
  }
  
  // MARK: - Private
  private func currentOffering() async throws -> Offering {
    try await withCheckedThrowingContinuation { continuation in
      Purchases.shared.getOfferings { offerings, error in
        if let error {
          continuation.resume(with: .failure(error))
          return
        }
        
        if let offering = offerings?.current {
          continuation.resume(with: .success(offering))
        } else {
          continuation.resume(with: .failure(Errors.failedToGetCurrentOffering))
        }
      }
    }
  }
}

extension InAppPurchases: PurchasesDelegate {
  func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
    subscribed = !customerInfo.entitlements.active.isEmpty
  }
}
