import PinLayout
import Popovers
import SwiftUI
import UIKit

final class PickerCell<Value: Hashable>: UICollectionViewListCell, ModelConfigurable {
  // MARK: - Properties
  var valueTitleProvider: ((Value, _ isPicker: Bool) -> String)?
  var onValueChanged: ((Value) -> Void)?
  
  // MARK: - UI Properties
  private lazy var iconImageView = createIconImageView()
  private lazy var titleLabel = createTitleLabel()
  private lazy var valueButton = createValueButton()
  
  // MARK: - ModelConfigurable
  func update(with model: PickerCellVM<Value>) {
    iconImageView.image = model.icon
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
  
  // MARK: - Override
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutViews()
  }
  
  // MARK: - Private
  private func layoutViews() {
    // icon
    iconImageView.pin
      .vCenter()
      .left(Inset.Padding.default)
      .size(Size.Icon.default)
    
    // value
    valueButton.pin
      .vCenter()
      .right(Inset.Padding.default)
      .maxWidth(50%)
      .sizeToFit()
    
    // title
    let titlePin = titleLabel.pin
      .top()
      .bottom()
      .before(of: valueButton)
    
    if iconImageView.image == nil {
      titlePin.left(Inset.Padding.default)
    } else {
      titlePin.after(of: iconImageView).marginLeft(Inset.Padding.default)
    }
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
      $0.textAlignment = .left
      contentView.addSubview($0)
    }
  }
  
  private func createValueButton() -> UIButton {
    with(UIButton(type: .system)) {
      $0.titleLabel?.font = Font.system(.body, weight: .regular)
      $0.titleLabel?.textAlignment = .right
      $0.tintColor = Color.Button.default
      contentView.addSubview($0)
    }
  }
  
  // MARK: - WheelView
  private struct WheelView<Value: Hashable>: SwiftUI.View {
    let values: [Value]
    @State var selected: Value
    let valueTitleProvider: (Value) -> String
    let onChange: (Value) -> Void
    
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
      .onChange(of: selected) { value in
        onChange(value)
      }
    }
  }
}
