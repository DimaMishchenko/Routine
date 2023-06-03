import SwiftUI

struct PremiumView<VM: PremiumViewModel>: View {
  // MARK: - Dependencies
  @ObservedObject private var viewModel: VM
  
  init(viewModel: VM) {
    self.viewModel = viewModel
  }
  
  // MARK: - Public
  var body: some View {
    VStack {
      List(viewModel.items) {
        Cell(item: $0)
          .listRowInsets(
            EdgeInsets(
              top: Inset.Padding.smedium,
              leading: Inset.Padding.default,
              bottom: Inset.Padding.small,
              trailing: Inset.Padding.smedium
            )
          )
      }
      .listStyle(.sidebar)
      
      VStack {
        if viewModel.isPremium {
          Manage { viewModel.manage() }
        } else if viewModel.offers.isEmpty {
          Text(RoutineAppStrings.Premium.Offer.noOffers)
            .font(Font.system(size: .body, weight: .regular))
            .foregroundColor(SwiftUI.Color(Color.Text.value))
        } else {
          ForEach(viewModel.offers) {
            Offer(offer: $0) {
              viewModel.purchase(id: $0)
            }
          }
        }
      }
      .padding([.leading, .trailing], Inset.Padding.default)
      .background(SwiftUI.Color(Color.Background.default))
    }
    .padding(.top, Inset.Padding.big)
  }
  
  private struct Cell: View {
    let item: Premium.Item
    
    var body: some View {
      HStack(spacing: Inset.Padding.default) {
        SwiftUI.Image(uiImage: item.icon)
          .resizable()
          .frame(width: Size.Icon.big, height: Size.Icon.big)
          .cornerRadius(Size.CornerRadius.button)
        
        VStack(alignment: .leading, spacing: 2) {
          Text(item.title)
            .font(Font.system(size: .body, weight: .semibold))
          
          Text(item.description)
            .font(Font.system(size: .body, weight: .regular))
            .foregroundColor(SwiftUI.Color(Color.Text.value))
        }
      }
    }
  }
  
  private struct Offer: View {
    let offer: Premium.Offer
    let action: (String) -> Void
    
    var body: some View {
      VStack {
        Button {
          action(offer.id)
        } label: {
          Text(offer.title)
            .font(SwiftUI.Font(Font.system(.body, weight: .medium)))
            .frame(maxWidth: .infinity, maxHeight: Size.Button.big)
            .foregroundColor(SwiftUI.Color(Color.Text.light))
            .background(SwiftUI.Color(Color.Button.default))
            .cornerRadius(Size.CornerRadius.buttonBig)
            .contentShape(Rectangle()) 
        }
        if let trial = offer.trialDescription {
          Text(trial)
            .font(Font.system(size: .body, weight: .regular))
            .foregroundColor(SwiftUI.Color(Color.Text.value))
        }
      }
    }
  }
  
  private struct Manage: View {
    let manage: () -> Void
    
    var body: some View {
      VStack {
        Text(RoutineAppStrings.Premium.Purchased.status)
          .font(Font.system(size: .body, weight: .regular))
          .foregroundColor(SwiftUI.Color(Color.Text.value))
        
        Button {
          manage()
        } label: {
          Text(RoutineAppStrings.Premium.Purchased.manage)
            .font(Font.system(size: .body, weight: .regular))
        }
      }
    }
  }
}

#if DEBUG
// MARK: - Preview
struct PremiumView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      PremiumView(viewModel: VMMock())
        .navigationTitle("Routine premium")
    }
  }
  
  class VMMock: PremiumViewModel {
    let items: [Premium.Item] = [
      .init(
        icon: RoutineAppAsset.Icon.appIcon.image,
        title: "Unlimited routines",
        description: "Add as many routines as you wish and view them in one convenient place."
      ),
      .init(
        icon: RoutineAppAsset.Icon.appIcon.image,
        title: "Enhanced security",
        description: "Enable biometric authentication to secure all of your information."
      )
    ]
    let offers: [Premium.Offer] = [
      .init(id: "1", title: "Subscribe 1.99 / Month", trialDescription: "1 week free"),
      .init(id: "2", title: "Subscribe 9.99 / Year", trialDescription: "1 week free")
    ]
    
    var isPremium = false
    
    func restore() {}
    func close() {}
    func purchase(id: String) {}
    func manage() {}
    func redeem() {}
  }
}
#endif
