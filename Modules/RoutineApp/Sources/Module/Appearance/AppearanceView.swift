import SwiftUI

struct AppearanceView<VM: AppearanceViewModel>: View {
  // MARK: - Dependencies
  @ObservedObject private var viewModel: VM
  @State private var isSystemSettings: Bool
  
  init(viewModel: VM) {
    self.viewModel = viewModel
    self.isSystemSettings = viewModel.theme == .system
  }
  
  // MARK: - Public
  var body: some View {
    List {
      Section {
        Cell(
          isSelected: viewModel.theme == .light,
          imageName: RoutineAppAsset.Icon.light.name,
          selectedImageName: RoutineAppAsset.Icon.lightSelected.name,
          text: RoutineAppStrings.Appearance.Text.light
        ).onTapGesture {
          viewModel.theme = .light
        }
        
        Cell(
          isSelected: viewModel.theme == .dark,
          imageName: RoutineAppAsset.Icon.dark.name,
          selectedImageName: RoutineAppAsset.Icon.darkSelected.name,
          text: RoutineAppStrings.Appearance.Text.dark
        ).onTapGesture {
          viewModel.theme = .dark
        }
      }
      
      Section {
        HStack {
          Toggle(
            RoutineAppStrings.Appearance.Text.useDeviceSettings,
            isOn: $isSystemSettings
          )
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
        Text(RoutineAppStrings.Appearance.Text.hint)
          .font(Font.system(size: .caption1, weight: .medium))
      }
    }
    .listStyle(.insetGrouped)
  }
  
  private struct Cell: View {
    let isSelected: Bool
    let imageName: String
    let selectedImageName: String
    let text: String
    
    var body: some View {
      HStack(spacing: .zero) {
        Image(isSelected ? selectedImageName : imageName)
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
// MARK: - Preview
struct AppearanceView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      AppearanceView(viewModel: VMMock())
        .navigationTitle("Appearance")
    }
  }
  
  class VMMock: AppearanceViewModel {
    @Published var theme: Theme = .system
  }
}
#endif
