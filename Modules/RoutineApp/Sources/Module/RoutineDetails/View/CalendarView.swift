import SnapKit
import SwiftUI

struct CalendarVM {
  let selections: [Selection]
  
  struct Selection {
    let emoji: String
    let date: Date
  }
}

struct CalendarView: UIViewRepresentable {
  let viewModel: CalendarVM
  let onSelection: (Date) -> Void
  let onDeselection: (Date) -> Void

  func makeUIView(context: Context) -> ContainerView {
    with(ContainerView()) {
      $0.calendar.calendar = context.coordinator.calendar
    }
  }

  func updateUIView(_ container: ContainerView, context: Context) {
    context.coordinator.viewModel = viewModel
    container.calendar.delegate = context.coordinator
    container.calendar.selectionBehavior = with(UICalendarSelectionMultiDate(delegate: context.coordinator)) {
      $0.selectedDates = viewModel.selections
        .map { $0.date }
        .compactMap { context.coordinator.calendar.dateComponents([.day, .month, .year], from: $0) }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(
      calendar: Calendar.app,
      viewModel: viewModel,
      onSelection: onSelection,
      onDeselection: onDeselection
    )
  }
}

extension CalendarView {
  final class ContainerView: UIView {
    fileprivate let calendar = UICalendarView()

    override init(frame: CGRect) {
      super.init(frame: .zero)
      addSubview(calendar)
      calendar.snp.makeConstraints {
        $0.edges.equalToSuperview()
      }
    }

    @available(*, unavailable, message: "Not supported")
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }

  final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionMultiDateDelegate {
    fileprivate let calendar: Calendar
    fileprivate var viewModel: CalendarVM
    private let onSelection: (Date) -> Void
    private let onDeselection: (Date) -> Void
    init(
      calendar: Calendar,
      viewModel: CalendarVM,
      onSelection: @escaping (Date) -> Void,
      onDeselection: @escaping (Date) -> Void
    ) {
      self.calendar = calendar
      self.viewModel = viewModel
      self.onSelection = onSelection
      self.onDeselection = onDeselection
    }
    func calendarView(
      _ calendarView: UICalendarView,
      decorationFor dateComponents: DateComponents
    ) -> UICalendarView.Decoration? {
      if dateComponents.date?.isInToday == true {
        return .default(color: Color.Button.default, size: .small)
      }

      if let selection = viewModel.selections.first(where: { dateComponents.date?.isInSameDay(as: $0.date) == true }) {
        return .customView {
          with(UILabel()) {
            $0.text = selection.emoji
            $0.font = .systemFont(ofSize: 13)
          }
        }
      }

      return nil
    }
    private func update(selection: UICalendarSelectionMultiDate) {
      selection.selectedDates = viewModel.selections
        .map { $0.date }
        .compactMap { calendar.dateComponents([.day, .month, .year], from: $0) }
    }
    func multiDateSelection(
      _ selection: UICalendarSelectionMultiDate,
      didSelectDate dateComponents: DateComponents
    ) {
      update(selection: selection)
      calendar.date(from: dateComponents).flatMap { onSelection($0) }
    }

    func multiDateSelection(
      _ selection: UICalendarSelectionMultiDate,
      didDeselectDate dateComponents: DateComponents
    ) {
      update(selection: selection)
      calendar.date(from: dateComponents).flatMap { onDeselection($0) }
    }

    func multiDateSelection(
      _ selection: UICalendarSelectionMultiDate,
      canSelectDate dateComponents: DateComponents
    ) -> Bool {
      true
    }

    func multiDateSelection(
      _ selection: UICalendarSelectionMultiDate,
      canDeselectDate dateComponents: DateComponents
    ) -> Bool {
      true
    }
  }
}

#if DEBUG
struct CalendarView_Previews: PreviewProvider {
  static var previews: some View {
    CalendarView(
      viewModel: .init(
        // swiftlint:disable:next force_unwrapping
        selections: [Date(), Date().byAddingDay!, Date().byAddingDay!.byAddingDay!].map {
          .init(emoji: "✅", date: $0)
        }
      ),
      onSelection: { _ in },
      onDeselection: { _ in }
    )
    .padding()
  }
}
#endif
