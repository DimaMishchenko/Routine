import SwiftUI

struct MenuView<VM: NavigationViewModel>: View {
  // MARK: - Dependencies
  @ObservedObject private var viewModel: VM
  
  init(viewModel: VM) {
    self.viewModel = viewModel
  }
  
  // MARK: - Public
  var body: some View {
    List(viewModel.items, id: \.type, selection: $viewModel.selectedItem) { item in
      Label {
        Text(item.title)
          .foregroundColor(
            viewModel.selectedItem == item ? SwiftUI.Color(Color.Text.light) : SwiftUI.Color(Color.Text.default)
          )
      } icon: {
        Image(uiImage: item.image)
          .renderingMode(.template)
          .foregroundColor(
            viewModel.selectedItem == item ? SwiftUI.Color(Color.Text.light) : SwiftUI.Color(Color.Button.default)
          )
      }
      .tag(item)
    }
    .listStyle(.sidebar)
  }
}

#if DEBUG
// MARK: - Preview
struct MenuView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      MenuView(viewModel: VMMock())
        .navigationTitle("Routine")
    }
  }
  
  final class VMMock: NavigationViewModel {
    var items: [Navigation.ItemVM] = [
      .init(
        type: .home,
        title: "Home",
        image: RoutineAppAsset.Icon.home.image,
        selectedImage: RoutineAppAsset.Icon.homeSelected.image
      ),
      .init(
        type: .settings,
        title: "Settings",
        image: RoutineAppAsset.Icon.settings.image,
        selectedImage: RoutineAppAsset.Icon.settingsSelected.image
      )
    ]
    @Published var selectedItem: Navigation.ItemVM?
    var selectedItemPublisher: Published<Navigation.ItemVM?>.Publisher { $selectedItem }

    init() { selectedItem = items.first }
    
    func viewDidLoad() {}
  }
}
#endif
