import SnapKit
import SwiftUI

struct CalendarVM {
  let selections: [Selection]
  
  struct Selection {
    let emoji: String
    let date: Date
  }
}

// swiftlint:disable all
//@available(iOS 16.0, *)
//struct CalendarView: UIViewRepresentable {
//  let viewModel: CalendarVM
//
//  func makeUIView(context: Context) -> ContainerView {
//    with(ContainerView()) {
//      $0.calendar.calendar = context.coordinator.calendar
//    }
//  }
//
//  func updateUIView(_ container: ContainerView, context: Context) {
//    container.calendar.delegate = context.coordinator
//    container.calendar.selectionBehavior = with(UICalendarSelectionMultiDate(delegate: context.coordinator)) {
//      $0.selectedDates = viewModel.selections
//        .map { $0.date }
//        .compactMap { context.coordinator.calendar.dateComponents([.day, .month, .year], from: $0) }
//    }
//  }
//
//  func makeCoordinator() -> Coordinator {
//    Coordinator(calendar: Calendar.app, viewModel: viewModel)
//  }
//}
//
//@available(iOS 16.0, *)
//extension CalendarView {
//  final class ContainerView: UIView {
//    fileprivate let calendar = UICalendarView()
//
//    override init(frame: CGRect) {
//      super.init(frame: .zero)
//      addSubview(calendar)
//      calendar.snp.makeConstraints {
//        $0.edges.equalToSuperview()
//      }
//    }
//
//    @available(*, unavailable, message: "Not supported")
//    required init?(coder: NSCoder) {
//      fatalError("init(coder:) has not been implemented")
//    }
//  }
//
//  final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionMultiDateDelegate {
//    // MARK: - Properties
//    fileprivate let calendar: Calendar
//    private let viewModel: CalendarVM
//
//    // MARK: - Init
//    init(calendar: Calendar, viewModel: CalendarVM) {
//      self.calendar = calendar
//      self.viewModel = viewModel
//    }
//
//    // MARK: - UICalendarViewDelegate
//    func calendarView(
//      _ calendarView: UICalendarView,
//      decorationFor dateComponents: DateComponents
//    ) -> UICalendarView.Decoration? {
//      if dateComponents.date?.isInToday == true {
//        return .default(color: Color.Button.default, size: .small)
//      }
//
//      if let selection = viewModel.selections.first(where: { dateComponents.date?.isInSameDay(as: $0.date) == true }) {
//        return .customView {
//          with(UILabel()) {
//            $0.text = selection.emoji
//            $0.font = .systemFont(ofSize: 13)
//          }
//        }
//      }
//
//      return nil
//    }
//
//    // MARK: - UICalendarSelectionMultiDateDelegate
//    func multiDateSelection(
//      _ selection: UICalendarSelectionMultiDate,
//      didSelectDate dateComponents: DateComponents
//    ) {
//      selection.selectedDates = viewModel.selections
//        .map { $0.date }
//        .compactMap { calendar.dateComponents([.day, .month, .year], from: $0) }
//    }
//
//    func multiDateSelection(
//      _ selection: UICalendarSelectionMultiDate,
//      didDeselectDate dateComponents: DateComponents
//    ) {}
//
//    func multiDateSelection(
//      _ selection: UICalendarSelectionMultiDate,
//      canSelectDate dateComponents: DateComponents
//    ) -> Bool {
//      true
//    }
//
//    func multiDateSelection(
//      _ selection: UICalendarSelectionMultiDate,
//      canDeselectDate dateComponents: DateComponents
//    ) -> Bool {
//      false
//    }
//  }
//}
//
//#if DEBUG
//// MARK: - Preview
//@available(iOS 16.0, *)
//struct CalendarView_Previews: PreviewProvider {
//  static var previews: some View {
//    CalendarView(
//      viewModel: .init(
//        // swiftlint:disable:next force_unwrapping
//        selections: [Date(), Date().byAddingDay!, Date().byAddingDay!.byAddingDay!].map {
//          .init(emoji: "✅", date: $0)
//        }
//      )
//    )
//    .padding()
//  }
//}
//#endif
// swiftlint:enable all
