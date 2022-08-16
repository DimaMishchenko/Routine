import ActionSheetPicker_3_0

enum SheetPicker {
  static func string(
    title: String,
    items: [String],
    selectedIndex: Int,
    from origin: UIView,
    completion: @escaping (Int) -> Void
  ) {
    ActionSheetStringPicker.show(
      withTitle: title,
      rows: items,
      initialSelection: selectedIndex,
      doneBlock: { _, index, _ in completion(index) },
      cancel: nil,
      origin: origin
    )
  }
  
  static func time(
    title: String,
    selectedDate: Date,
    from origin: UIView,
    completion: @escaping (Date) -> Void
  ) {
    ActionSheetDatePicker.show(
      withTitle: title,
      datePickerMode: .time,
      selectedDate: selectedDate,
      doneBlock: { _, date, _ in
        guard let date = date as? Date else { return }
        completion(date)
      },
      cancel: nil,
      origin: origin
    )
  }
}
