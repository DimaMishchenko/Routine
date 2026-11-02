import SwiftUI
import UIKit

struct FreeAnnouncementView: View {
  enum Context {
    case announcement
    case support
  }

  var context: Context = .announcement
  let onContinue: () -> Void
  @SwiftUI.Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        StoryView(context: context)

        adaptiveLayout {
          if let url = AppConfiguration.dimaAuthorLink {
            authorLink(image: RoutineAppAsset.Icon.dimasike.image, url: url)
          }
          if let url = AppConfiguration.mishaAuthorLink {
            authorLink(image: RoutineAppAsset.Icon.misha.image, url: url)
          }
        }

        VStack(alignment: .leading, spacing: Inset.Padding.default) {
          Text(RoutineAppStrings.Localizable.FreeAnnouncement.support)
            .fixedSize(horizontal: false, vertical: true)
          adaptiveLayout {
            if let url = AppConfiguration.appLink {
              ShareLink(item: url) {
                actionLabel(RoutineAppStrings.Localizable.Settings.Row.shareApp, symbol: "square.and.arrow.up")
              }
            }
            Button(action: ExternalLinksNavigator.writeReview) {
              actionLabel(String(localized: "support.review"), symbol: "star")
            }
          }
          .buttonStyle(.glass)
        }
        .controlSize(.large)
      }
      .frame(maxWidth: 512, alignment: .leading)
      .padding(.horizontal, 24)
      .padding(.top, 48)
      .padding(.bottom, 24)
      .frame(maxWidth: .infinity)
    }
    .safeAreaInset(edge: .bottom) {
      if context == .announcement {
        Button(action: onContinue) {
          Text(RoutineAppStrings.Localizable.FreeAnnouncement.continue)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .frame(maxWidth: 480)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
      }
    }
    .background(SwiftUI.Color(Color.Background.default))
    .tint(SwiftUI.Color(Color.tint))
  }

  struct StoryView: View {
    let context: Context

    var body: some View {
      VStack(alignment: .leading, spacing: Inset.Padding.default) {
        title
          .frame(maxWidth: .infinity, alignment: .leading)
          .multilineTextAlignment(.leading)
        Text(String(localized: "support.story.beginning"))
        Text(String(localized: "support.story.pause"))
        Text(String(localized: "support.story.return") + " 🌱")
      }
      .fixedSize(horizontal: false, vertical: true)
    }

    private var title: some View {
      Text(context == .announcement
           ? RoutineAppStrings.Localizable.FreeAnnouncement.title
           : String(localized: "support.story.title") + " 👋")
        .font(.system(.largeTitle, design: .rounded, weight: .bold))
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  private var adaptiveLayout: AnyLayout {
    dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(spacing: Inset.Padding.default))
      : AnyLayout(HStackLayout(spacing: Inset.Padding.default))
  }

  private func actionLabel(_ title: String, symbol: String) -> some View {
    Label(title, systemImage: symbol)
      .font(.body)
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
      .frame(maxWidth: .infinity)
      .padding(.vertical, Inset.Padding.small)
      .contentShape(Rectangle())
  }

  private func authorLink(image: UIImage, url: URL) -> some View {
    Link(destination: url) {
      VStack(spacing: Inset.Padding.small) {
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
          .frame(width: 64, height: 64)
          .clipShape(Circle())
          .accessibilityHidden(true)
        Text("@" + url.lastPathComponent)
          .font(.subheadline)
          .foregroundStyle(SwiftUI.Color(Color.tint))
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(maxWidth: .infinity)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
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
