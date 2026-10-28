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

  func makeUIView(context: Context) -> UICalendarView {
    with(UICalendarView()) {
      $0.calendar = context.coordinator.calendar
      $0.delegate = context.coordinator
      $0.selectionBehavior = UICalendarSelectionMultiDate(delegate: context.coordinator)
    }
  }

  func updateUIView(_ calendarView: UICalendarView, context: Context) {
    let previousSelections = context.coordinator.viewModel.selections
    context.coordinator.viewModel = viewModel
    let selectedDates = viewModel.selections.map {
      context.coordinator.calendar.dateComponents([.day, .month, .year], from: $0.date)
    }
    if let selection = calendarView.selectionBehavior as? UICalendarSelectionMultiDate,
      selection.selectedDates != selectedDates {
      selection.setSelectedDates(selectedDates, animated: false)
    }
    calendarView.reloadDecorations(
      forDateComponents: (previousSelections + viewModel.selections).map {
        context.coordinator.calendar.dateComponents([.day, .month, .year], from: $0.date)
      },
      animated: false
    )
  }

  func sizeThatFits(_ proposal: ProposedViewSize, uiView: UICalendarView, context: Context) -> CGSize? {
    let size = uiView.intrinsicContentSize
    return CGSize(width: min(proposal.width ?? size.width, size.width), height: size.height)
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
        selections: (0..<3).compactMap { Calendar.app.date(byAdding: .day, value: $0, to: Date()) }.map {
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
