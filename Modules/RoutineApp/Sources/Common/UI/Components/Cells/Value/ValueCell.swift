import SnapKit
import UIKit

final class ValueCell: UICollectionViewListCell, ModelConfigurable {
  var valueSourceView: UIView { valueLabel }

  private let iconImageView = UIImageView()
  private let titleLabel = UILabel()
  private let valueLabel = UILabel()
  private let labelsStack = UIStackView()
  private var valueWidthConstraint: NSLayoutConstraint?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    updateLabelLayout()
    registerForTraitChanges(
      [UITraitPreferredContentSizeCategory.self, UITraitLayoutDirection.self]
    ) { (cell: ValueCell, _: UITraitCollection) in
      cell.updateLabelLayout()
    }
  }

  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(with model: ValueCellVM) {
    iconImageView.image = model.icon
    iconImageView.isHidden = model.icon == nil
    titleLabel.text = model.title
    valueLabel.textColor = Color.Text.value

    switch model.value {
    case let .text(text, style):
      valueLabel.text = text
      if case .bold = style {
        valueLabel.textColor = Color.Text.default
      }
    case .emoji(let emoji):
      valueLabel.text = emoji
    default:
      valueLabel.text = nil
    }
    valueLabel.isHidden = valueLabel.text?.isEmpty != false

    switch model.accessory {
    case .none:
      accessories = []
    case .disclosure:
      accessories = [.disclosureIndicator()]
    }
    accessibilityLabel = model.title
    accessibilityValue = valueLabel.text
  }

  private func setupUI() {
    isAccessibilityElement = true
    titleLabel.font = Font.system(.body, weight: .regular)
    titleLabel.adjustsFontForContentSizeCategory = true
    titleLabel.textColor = Color.Text.default
    titleLabel.textAlignment = .natural
    titleLabel.numberOfLines = .zero
    titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    valueLabel.font = Font.system(.body, weight: .regular)
    valueLabel.adjustsFontForContentSizeCategory = true
    valueLabel.numberOfLines = .zero
    valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    iconImageView.contentMode = .scaleAspectFit
    iconImageView.snp.makeConstraints { $0.size.equalTo(Size.Icon.default).priority(999) }

    labelsStack.spacing = Inset.Padding.small
    labelsStack.addArrangedSubview(titleLabel)
    labelsStack.addArrangedSubview(valueLabel)

    let row = UIStackView(arrangedSubviews: [iconImageView, labelsStack])
    row.spacing = Inset.Padding.default
    row.alignment = .center
    contentView.addSubview(row)
    row.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(Inset.Padding.default)
      $0.top.bottom.equalToSuperview().inset(Inset.Padding.small)
      $0.height.greaterThanOrEqualTo(Size.View.cellDefault - 2 * Inset.Padding.small)
    }
    valueWidthConstraint = valueLabel.widthAnchor.constraint(
      lessThanOrEqualTo: labelsStack.widthAnchor,
      multiplier: 0.5
    )
  }

  private func updateLabelLayout() {
    let accessibilitySize = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
    labelsStack.axis = accessibilitySize ? .vertical : .horizontal
    labelsStack.alignment = accessibilitySize ? .fill : .center
    valueWidthConstraint?.isActive = !accessibilitySize
    if accessibilitySize {
      valueLabel.textAlignment = .natural
    } else {
      valueLabel.textAlignment = effectiveUserInterfaceLayoutDirection == .rightToLeft ? .left : .right
    }
  }
}
