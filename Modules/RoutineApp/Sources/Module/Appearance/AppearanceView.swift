import SwiftUI

struct AppearanceView<VM: AppearanceViewModel>: View {
  @ObservedObject private var viewModel: VM
  @State private var isSystemSettings: Bool
  
  init(viewModel: VM) {
    self.viewModel = viewModel
    self.isSystemSettings = viewModel.theme == .system
  }
  
  var body: some View {
    List {
      Section {
        Cell(
          isSelected: viewModel.theme == .light,
          symbolName: "sun.max",
          color: .orange,
          text: RoutineAppStrings.Localizable.Appearance.Text.light
        ).onTapGesture {
          viewModel.theme = .light
        }
        
        Cell(
          isSelected: viewModel.theme == .dark,
          symbolName: "moon",
          color: .indigo,
          text: RoutineAppStrings.Localizable.Appearance.Text.dark
        ).onTapGesture {
          viewModel.theme = .dark
        }
      }
      
      Section {
        HStack {
          Toggle(
            RoutineAppStrings.Localizable.Appearance.Text.useDeviceSettings,
            isOn: $isSystemSettings
          )
          .toggleStyle(.switch)
          .onChange(of: viewModel.theme) { newValue in
            isSystemSettings = newValue == .system
          }
          .onChange(of: isSystemSettings) { newValue in
            viewModel.theme = newValue ?
              .system :
              (viewModel.theme == .system ? .light : viewModel.theme)
          }
        }
      } footer: {
        Text(RoutineAppStrings.Localizable.Appearance.Text.hint)
          .font(Font.system(size: .caption1, weight: .medium))
      }

      Section {
        Toggle(
          RoutineAppStrings.Localizable.Appearance.Text.confettiAnimation,
          isOn: $viewModel.confettiEnabled
        )
        .toggleStyle(.switch)
      }
    }
    .listStyle(.insetGrouped)
    .containerRelativeFrame(.horizontal) { width, _ in Size.View.contentWidth(for: width) }
    .frame(maxWidth: .infinity)
    .background(SwiftUI.Color(Color.Background.default))
  }
  
  private struct Cell: View {
    let isSelected: Bool
    let symbolName: String
    let color: SwiftUI.Color
    let text: String
    
    var body: some View {
      HStack(spacing: .zero) {
        Image(systemName: symbolName)
          .font(.system(size: 22, weight: .regular))
          .symbolRenderingMode(.monochrome)
          .foregroundStyle(color)
          .frame(width: 30, height: 30)
          .accessibilityHidden(true)
          .padding(.trailing, Inset.Padding.default)
        Text(text)
        Spacer()
        if isSelected {
          Image(systemName: "checkmark")
            .foregroundColor(SwiftUI.Color(Color.Button.default))
        }
      }
      .contentShape(Rectangle())
    }
  }
}

#if DEBUG
struct AppearanceView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      AppearanceView(viewModel: VMMock())
        .navigationTitle("Appearance")
    }
  }
  
  class VMMock: AppearanceViewModel {
    @Published var theme: Theme = .system
    @Published var confettiEnabled = true
  }
}
#endif
