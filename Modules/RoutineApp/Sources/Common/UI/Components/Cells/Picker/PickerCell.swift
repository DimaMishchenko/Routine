import Popovers
import SnapKit
import SwiftUI
import UIKit

final class PickerCell<Value: Hashable>: UICollectionViewListCell, ModelConfigurable {
  var valueTitleProvider: ((Value, _ isPicker: Bool) -> String)?
  var onValueChanged: ((Value) -> Void)?
  
  private lazy var iconImageView = createIconImageView()
  private lazy var titleLabel = createTitleLabel()
  private lazy var valueButton = createValueButton()
  private let labelsStack = UIStackView()
  private var valueWidthConstraint: NSLayoutConstraint?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayout()
    updateLabelLayout()
    registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (cell: PickerCell, _: UITraitCollection) in
      cell.updateLabelLayout()
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  func update(with model: PickerCellVM<Value>) {
    iconImageView.image = model.icon
    iconImageView.isHidden = model.icon == nil
    titleLabel.text = model.title
    valueButton.setTitle(valueTitleProvider?(model.selected, false) ?? "\(model.selected)", for: .normal)
    
    switch model.style {
    case .wheel:
      valueButton.on { [weak self, model] in
        let popover = Popover(
          attributes: Popover.Attributes(
            position: .absolute(originAnchor: .left, popoverAnchor: .right),
            sourceFrame: { self?.valueButton.windowFrame() ?? .zero },
            sourceFrameInset: .init(top: .zero, left: -Inset.Padding.small, bottom: .zero, right: .zero),
            rubberBandingMode: .none,
            onDismiss: {}
          )
        ) {
          WheelView(
            values: model.values,
            selected: model.selected,
            valueTitleProvider: { self?.valueTitleProvider?($0, true) ?? "\($0)" },
            onChange: { self?.onValueChanged?($0) }
          )
        }
        self?.parentVC?.present(popover)
      }
    case .menu:
      valueButton.showsMenuAsPrimaryAction = true
      valueButton.menu = UIMenu(children: model.values.map { value in
        UIAction(title: valueTitleProvider?(value, true) ?? "\(value)") { [weak self] _ in
          self?.onValueChanged?(value)
        }
      })
    }
  }
  
  private func setupLayout() {
    labelsStack.addArrangedSubview(titleLabel)
    labelsStack.addArrangedSubview(valueButton)
    labelsStack.spacing = Inset.Padding.small
    let row = UIStackView(arrangedSubviews: [iconImageView, labelsStack])
    row.spacing = Inset.Padding.default
    row.alignment = .center
    contentView.addSubview(row)
    iconImageView.snp.makeConstraints { $0.size.equalTo(Size.Icon.default).priority(999) }
    row.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(Inset.Padding.default)
      $0.top.bottom.equalToSuperview().inset(Inset.Padding.small)
      $0.height.greaterThanOrEqualTo(Size.View.cellDefault - 2 * Inset.Padding.small)
    }
    valueWidthConstraint = valueButton.widthAnchor.constraint(
      lessThanOrEqualTo: labelsStack.widthAnchor,
      multiplier: 0.5
    )
  }

  private func updateLabelLayout() {
    let accessibilitySize = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
    labelsStack.axis = accessibilitySize ? .vertical : .horizontal
    labelsStack.alignment = accessibilitySize ? .leading : .center
    valueWidthConstraint?.isActive = !accessibilitySize
    valueButton.contentHorizontalAlignment = accessibilitySize ? .leading : .trailing
  }

  private func createIconImageView() -> UIImageView {
    with(UIImageView()) {
      contentView.addSubview($0)
    }
  }
  
  private func createTitleLabel() -> UILabel {
    with(UILabel()) {
      $0.font = Font.system(.body, weight: .regular)
      $0.textColor = Color.Text.default
      $0.textAlignment = .natural
      $0.numberOfLines = .zero
      $0.adjustsFontForContentSizeCategory = true
      $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
      contentView.addSubview($0)
    }
  }
  
  private func createValueButton() -> UIButton {
    with(UIButton(type: .system)) {
      $0.titleLabel?.font = Font.system(.body, weight: .regular)
      $0.titleLabel?.textAlignment = .natural
      $0.titleLabel?.numberOfLines = .zero
      $0.titleLabel?.adjustsFontForContentSizeCategory = true
      $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      $0.tintColor = Color.Button.default
      contentView.addSubview($0)
    }
  }
  
  private struct WheelView<Choice: Hashable>: SwiftUI.View {
    let values: [Choice]
    @State var selected: Choice
    let valueTitleProvider: (Choice) -> String
    let onChange: (Choice) -> Void
    
    var body: some SwiftUI.View {
      Picker("", selection: $selected) {
        ForEach(values, id: \.self) {
          Text(valueTitleProvider($0))
        }
      }
      .frame(width: 200)
      .pickerStyle(.wheel)
      .cornerRadius(Size.CornerRadius.container)
      .mask(
        SwiftUI.Color.clear
          .overlay(
            RoundedRectangle(cornerRadius: Size.CornerRadius.container),
            alignment: .top
          )
      )
      .background(
        Templates.VisualEffectView(.prominent)
          .cornerRadius(Size.CornerRadius.container)
          .popoverShadow(
            shadow: with(.system) {
              $0.color = SwiftUI.Color(Color.black.withAlphaComponent(0.3))
            }
          ),
        alignment: .top
      )
      .onChange(of: selected) { _, value in
        onChange(value)
      }
    }
  }
}
