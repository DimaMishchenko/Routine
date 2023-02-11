import SwiftUI

struct TutorialView<VM: TutorialViewModel>: View {
  // MARK: - Dependencies
  @ObservedObject private var viewModel: VM

  // MARK: - Private Properties
  @State private var actionTitle: String
  @State private var showsFeatures = false

  // MARK: - Init
  init(viewModel: VM) {
    self.viewModel = viewModel
    actionTitle = viewModel.welcomeVM.actionTitle
  }

  // MARK: - Public
  var body: some View {
    GeometryReader { geometry in
      VStack {
        Spacer()
        if !showsFeatures {
          WelcomeView(vm: viewModel.welcomeVM, width: geometry.size.width)
        } else {
          FeaturesView(vm: viewModel.featuresVM)
        }
        Spacer()
        Button(actionTitle) {
          actionTitle = viewModel.featuresVM.actionTitle
          if !showsFeatures {
            showsFeatures = true
          } else {
            viewModel.close()
          }
        }
        .font(SwiftUI.Font(Font.system(.body, weight: .medium)))
        .frame(maxWidth: .infinity, maxHeight: Size.Button.big)
        .foregroundColor(SwiftUI.Color(Color.Text.light))
        .background(SwiftUI.Color(Color.Button.default))
        .cornerRadius(Size.CornerRadius.buttonBig)
      }
      .padding(Inset.Padding.default)
      .frame(width: geometry.size.width)
    }
  }

  struct WelcomeView: View {
    let vm: Tutorial.WelcomeVM
    let width: CGFloat

    var body: some View {
      VStack(spacing: Inset.Padding.small) {
        Image(uiImage: vm.icon)
          .resizable()
          .cornerRadius(20)
          .frame(width: 96, height: 96)

        Spacer().frame(height: Inset.Padding.default)

        UIKitLabel {
          $0.attributedText = vm.title
          $0.textAlignment = .center
          $0.numberOfLines = .zero
          $0.font = Font.system(.largeTitle, weight: .bold)
          $0.preferredMaxLayoutWidth = width - Inset.Padding.big
        }
        .fixedSize()

        Text(vm.description)
          .multilineTextAlignment(.center)
          .foregroundColor(SwiftUI.Color(Color.Text.value))
      }
    }
  }

  struct FeaturesView: View {
    let vm: Tutorial.FeaturesVM

    var body: some View {
      VStack(spacing: .zero) {
        VStack(spacing: Inset.Padding.small) {
          Text(vm.title)
            .multilineTextAlignment(.center)
            .font(SwiftUI.Font(Font.system(.largeTitle, weight: .bold)))

          Text(vm.message)
            .multilineTextAlignment(.center)
            .foregroundColor(SwiftUI.Color(Color.Text.value))
        }

        Spacer().frame(height: Inset.Padding.big)
        
        VStack(spacing: Inset.Padding.default) {
          ForEach(vm.features) {
            FeatureView(vm: $0)
          }
        }
      }
    }
  }

  struct FeatureView: View {
    let vm: Tutorial.FeatureVM

    var body: some View {
      HStack(spacing: Inset.Padding.default) {
        Image(uiImage: vm.icon)
          .resizable()
          .frame(width: 40, height: 40)

        VStack(alignment: .leading, spacing: Inset.Padding.extraSmall) {
          Text(vm.title)
            .font(SwiftUI.Font(Font.system(.body, weight: .semibold)))
          
          Text(vm.description)
            .font(SwiftUI.Font(Font.system(.body, weight: .regular)))
            .foregroundColor(SwiftUI.Color(Color.Text.value))
        }

        Spacer()
      }
    }
  }
}

#if DEBUG
// MARK: - Preview
struct TutorialView_Previews: PreviewProvider {
  static var previews: some View {
    TutorialView(viewModel: VMMock())
  }
  
  class VMMock: TutorialViewModel {
    let welcomeVM = Tutorial.WelcomeVM(
      icon: RoutineAppAsset.Icon.appIcon.image,
      title: NSAttributedString(string: "Welcome to Routine"),
      description: "Routine is a simple and fully native app for tracking your habits in one place.",
      actionTitle: "Continue"
    )
    
    let featuresVM = Tutorial.FeaturesVM(
      title: "Stay productive wherever you are",
      message: "Routine helps you create and maintain habits and allows you to achieve your goals.",
      actionTitle: "Get started",
      features: [
        .init(
          icon: RoutineAppAsset.Icon.tutorialCheckmark.image,
          title: "Unlimited routines",
          description: "You can create an unlimited number of routines"
        ),
        .init(
          icon: RoutineAppAsset.Icon.tutorialCloud.image,
          title: "iCloud sync",
          description: "Backup your data on any device – iPhone, iPad, and MacOS"
        ),
        .init(
          icon: RoutineAppAsset.Icon.tutorialChart.image,
          title: "Overview",
          description: "Clearly see how your routines improved over time with detailed charts"
        )
      ]
    )

    func close() {}
  }
}
#endif
