import SwiftUI
import UIKit

struct FreeAnnouncementView: View {
  let onContinue: () -> Void

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        Image(systemName: "gift.fill")
          .font(.system(size: 56))
          .foregroundStyle(SwiftUI.Color(Color.tint))
          .accessibilityHidden(true)
        Text(RoutineAppStrings.Localizable.FreeAnnouncement.title)
          .font(.largeTitle.bold())
          .multilineTextAlignment(.center)
        Text(RoutineAppStrings.Localizable.FreeAnnouncement.message)
          .font(.title3)
          .multilineTextAlignment(.center)
        Text(RoutineAppStrings.Localizable.FreeAnnouncement.features)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
        Divider()
        Text(RoutineAppStrings.Localizable.FreeAnnouncement.support)
          .multilineTextAlignment(.center)
        VStack(spacing: 12) {
          if let url = AppConfiguration.dimaAuthorLink {
            Link(RoutineAppStrings.Localizable.FreeAnnouncement.dima, destination: url)
          }
          if let url = AppConfiguration.mishaAuthorLink {
            Link(RoutineAppStrings.Localizable.FreeAnnouncement.misha, destination: url)
          }
        }
        .buttonStyle(.bordered)
      }
      .frame(maxWidth: 480)
      .padding(24)
      .frame(maxWidth: .infinity)
    }
    .safeAreaInset(edge: .bottom) {
      Button(RoutineAppStrings.Localizable.FreeAnnouncement.continue, action: onContinue)
        .font(.headline)
        .frame(maxWidth: 480)
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
    }
    .background(SwiftUI.Color(Color.Background.default))
    .tint(SwiftUI.Color(Color.tint))
  }
}

final class FreeAnnouncementVC: UIHostingController<FreeAnnouncementView> {
  var onAppear: (() -> Void)?

  init(onContinue: @escaping () -> Void) {
    super.init(rootView: FreeAnnouncementView(onContinue: onContinue))
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    onAppear?()
  }
}
