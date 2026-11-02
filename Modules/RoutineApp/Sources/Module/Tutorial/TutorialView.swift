import SwiftUI

struct TutorialView<VM: TutorialViewModel>: View {
  @ObservedObject private var viewModel: VM

  @State private var actionTitle: String
  @State private var showsFeatures = false

  init(viewModel: VM) {
    self.viewModel = viewModel
    actionTitle = viewModel.welcomeVM.actionTitle
  }

  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        Group {
          if showsFeatures {
            FeaturesView(vm: viewModel.featuresVM)
          } else {
            WelcomeView(vm: viewModel.welcomeVM)
          }
        }
        .frame(maxWidth: 512)
        .padding(.horizontal, 24)
        .padding(.top, showsFeatures ? 48 : 32)
        .padding(.bottom, showsFeatures ? 24 : 32)
        .frame(
          maxWidth: .infinity,
          minHeight: geometry.size.height,
          alignment: showsFeatures ? .top : .center
        )
      }
    }
    .safeAreaInset(edge: .bottom) {
      Button {
        if showsFeatures {
          viewModel.close()
        } else {
          showsFeatures = true
          actionTitle = viewModel.featuresVM.actionTitle
        }
      } label: {
        Text(actionTitle)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
      }
      .font(.headline)
      .buttonStyle(.glassProminent)
      .controlSize(.large)
      .frame(maxWidth: 480)
      .padding(.horizontal, 24)
      .padding(.vertical, 16)
      .frame(maxWidth: .infinity)
    }
    .background(SwiftUI.Color(Color.Background.default))
    .tint(SwiftUI.Color(Color.tint))
  }

  struct WelcomeView: View {
    let vm: Tutorial.WelcomeVM

    var body: some View {
      VStack(spacing: 16) {
        Image(uiImage: vm.icon)
          .resizable()
          .cornerRadius(20)
          .frame(width: 80, height: 80)
          .accessibilityHidden(true)

        VStack(spacing: 12) {
          Text(AttributedString(vm.title))
            .font(.system(.largeTitle, design: .rounded, weight: .bold))

          Text(vm.description)
            .font(.body)
            .foregroundColor(SwiftUI.Color(Color.Text.value))
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
      }
    }
  }

  struct FeaturesView: View {
    let vm: Tutorial.FeaturesVM

    var body: some View {
      VStack(alignment: .leading, spacing: 24) {
        VStack(alignment: .leading, spacing: 12) {
          Text(vm.title)
            .font(.system(.largeTitle, design: .rounded, weight: .bold))

          Text(vm.message)
            .font(.body)
            .foregroundColor(SwiftUI.Color(Color.Text.value))
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        
        VStack(spacing: 12) {
          ForEach(vm.features) {
            FeatureView(vm: $0)
          }
        }
      }
    }
  }

  struct FeatureView: View {
    @SwiftUI.Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let vm: Tutorial.FeatureVM

    var body: some View {
      let layout = dynamicTypeSize.isAccessibilitySize
        ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
        : AnyLayout(HStackLayout(alignment: .top, spacing: 16))

      layout {
        Image(uiImage: vm.icon)
          .resizable()
          .frame(width: 40, height: 40)

        VStack(alignment: .leading, spacing: Inset.Padding.extraSmall) {
          Text(vm.title)
            .font(.system(.body, design: .rounded, weight: .semibold))
          
          Text(vm.description)
            .font(.body)
            .foregroundColor(SwiftUI.Color(Color.Text.value))
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

#if DEBUG
struct TutorialView_Previews: PreviewProvider {
  static var previews: some View {
    TutorialView(viewModel: TutorialViewModelImpl())
  }
}
#endif
