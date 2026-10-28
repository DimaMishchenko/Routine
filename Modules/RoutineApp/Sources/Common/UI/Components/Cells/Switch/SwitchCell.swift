import SnapKit
import UIKit

final class SwitchCell: UICollectionViewCell, ModelConfigurable {
  var onChangeRequest: ((_ currentState: Bool) -> Void)?

  private let iconImageView = UIImageView()
  private let titleLabel = UILabel()
  private let switchView = UISwitch()
  private let controlsStack = UIStackView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundConfiguration = .listCell()
    setupUI()
    updateControlLayout()
    registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (cell: SwitchCell, _: UITraitCollection) in
      cell.updateControlLayout()
    }
  }

  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(with model: SwitchCellVM) {
    iconImageView.image = model.icon
    iconImageView.isHidden = model.icon == nil
    titleLabel.text = model.title
    switchView.accessibilityLabel = model.title
    switchView.setOn(model.state, animated: true)
  }

  private func updateControlLayout() {
    let accessibilitySize = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
    controlsStack.axis = accessibilitySize ? .vertical : .horizontal
    controlsStack.alignment = accessibilitySize ? .leading : .center
  }

  private func setupUI() {
    iconImageView.contentMode = .scaleAspectFit
    iconImageView.snp.makeConstraints { $0.size.equalTo(Size.Icon.default).priority(999) }

    titleLabel.font = Font.system(.body, weight: .regular)
    titleLabel.adjustsFontForContentSizeCategory = true
    titleLabel.textColor = Color.Text.default
    titleLabel.textAlignment = .natural
    titleLabel.numberOfLines = .zero
    titleLabel.isAccessibilityElement = false
    titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    switchView.setContentCompressionResistancePriority(.required, for: .horizontal)
    switchView.setContentHuggingPriority(.required, for: .horizontal)
    switchView.on(.valueChanged) { [weak self] in
      guard let self = self else { return }
      self.switchView.setOn(!self.switchView.isOn, animated: false)
      self.onChangeRequest?(self.switchView.isOn)
    }

    controlsStack.addArrangedSubview(titleLabel)
    controlsStack.addArrangedSubview(switchView)
    controlsStack.spacing = Inset.Padding.small
    let row = UIStackView(arrangedSubviews: [iconImageView, controlsStack])
    row.spacing = Inset.Padding.default
    row.alignment = .center
    contentView.addSubview(row)
    row.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(Inset.Padding.default)
      $0.top.bottom.equalToSuperview().inset(Inset.Padding.small)
      $0.height.greaterThanOrEqualTo(Size.View.cellDefault - 2 * Inset.Padding.small)
    }
  }
}
