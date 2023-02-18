import ProjectDescription

public enum AppExtension: CaseIterable {
  case notificationsService
}

// MARK: - Configuration
extension AppExtension {
  public var name: String {
    switch self {
    case .notificationsService:
      return "NotificationsService"
    }
  }

  public var bundleIdSuffix: String {
    switch self {
    case .notificationsService:
      return "notificationsService"
    }
  }

  public var deploymentTarget: DeploymentTarget {
    switch self {
    case .notificationsService:
      return .iOS(targetVersion: "14.0", devices: [.iphone, .ipad])
    }
  }

  public var productType: Product {
    switch self {
    case .notificationsService:
      return .appExtension
    }
  }

  public var infoPlist: InfoPlist {
    switch self {
    case .notificationsService:
      return .extendingDefault(
        with:
        [
          "NSExtension": [
            "NSExtensionPointIdentifier": "com.apple.usernotifications.service",
            "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).NotificationService"
          ],
          "CFBundleDisplayName": "NotificationsService",
          "CFBundleShortVersionString": .string(Version.appVersion)
        ]
      )
    }
  }

  public var sources: SourceFilesList {
    switch self {
    case .notificationsService:
      return "Modules/NotificationsService/**"
    }
  }

  public var entitlements: Path? {
    switch self {
    case .notificationsService:
      return "Modules/NotificationsService/NotificationsService.entitlements"
    }
  }

  public var dependencies: [TargetDependency] {
    switch self {
    case .notificationsService:
      return [.spm(.firebase(.messaging))]
    }
  }
}
