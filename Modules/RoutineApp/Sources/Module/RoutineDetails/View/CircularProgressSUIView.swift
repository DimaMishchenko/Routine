import SwiftUI

struct CircularProgressSUIView: View {
  let progress: Double
  let lineWidth: Double
  
  var body: some View {
    ZStack {
      Circle()
        .stroke(
          SwiftUI.Color(Color.Background.lightBlue ?? Color.Background.default),
          lineWidth: lineWidth
        )
      Circle()
        .trim(from: .zero, to: progress)
        .stroke(
          LinearGradient(
            colors: Color.Gradient.primary
              .compactMap { $0 }
              .map { SwiftUI.Color($0) },
            startPoint: .bottomTrailing,
            endPoint: .bottom
          ),
          style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        )
        .rotationEffect(.degrees(-90))
        .animation(.easeOut, value: progress)
      Text("\(Int(progress * 100))%")
        .foregroundColor(SwiftUI.Color(Color.Text.default))
        .font(Font.system(size: .largeTitle, weight: .bold))
    }
    .padding(lineWidth / 2)
  }
}

#if DEBUG
// MARK: - Preview
struct CircularProgressSUIView_Previews: PreviewProvider {
  static var previews: some View {
    CircularProgressSUIView(progress: 0.3, lineWidth: 30)
      .padding()
  }
}
#endif
