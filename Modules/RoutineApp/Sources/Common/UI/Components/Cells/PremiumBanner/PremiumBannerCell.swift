import PinLayout
import SnapKit
import UIKit

final class PremiumBannerCell: UICollectionViewListCell, ModelConfigurable {
  // MARK: - Properties
  var onClose: (() -> Void)?
  
  // MARK: - UI Properties
  private lazy var iconView = createIconView()
  private lazy var titleLabel = createTitleLabel()
  private lazy var descriptionLabel = createDescriptionLabel()
  private lazy var closeButton = createCloseButton()
  
  // MARK: - ModelConfigurable
  func update(with model: PremiumBannerCellVM) {
    titleLabel.text = "Routine Premium"
    descriptionLabel.text = "Get access to all the amazing features Routine has."
    switch model.accesory {
    case .close:
      accessories = []
      closeButton.isHidden = false
    case .disclosure:
      accessories = [.disclosureIndicator()]
      closeButton.isHidden = true
    }
    updateBackgroundConfiguration()
  }
  
  // MARK: - Private
  private func updateBackgroundConfiguration() {
    backgroundConfiguration = with(.clear()) {
      $0?.cornerRadius = Size.CornerRadius.container
      $0?.backgroundColor = Color.Background.secondary
    }
  }
  
  private func createIconView() -> UIImageView {
    with(UIImageView()) {
      contentView.addSubview($0)
      $0.image = RoutineAppAsset.Icon.appIcon.image
      $0.layer.cornerRadius = Size.CornerRadius.icon
      $0.clipsToBounds = true
      $0.snp.makeConstraints {
        $0.leading.equalToSuperview().offset(Inset.Padding.default)
        $0.centerY.equalToSuperview()
        $0.size.equalTo(Size.Icon.big)
      }
    }
  }
  
  private func createTitleLabel() -> UILabel {
    with(UILabel()) {
      $0.font = Font.system(.body, weight: .semibold)
      $0.numberOfLines = .zero
      $0.textColor = Color.Text.default
      $0.textAlignment = .left
      contentView.addSubview($0)
      
      $0.snp.makeConstraints {
        $0.top.equalToSuperview().offset(Inset.Padding.small)
        $0.leading.equalTo(iconView.snp.trailing).offset(Inset.Padding.default)
        $0.trailing.equalToSuperview().offset(-Inset.Padding.default)
      }
    }
  }
  
  private func createDescriptionLabel() -> UILabel {
    with(UILabel()) {
      $0.font = Font.system(.body, weight: .regular)
      $0.numberOfLines = .zero
      $0.textColor = Color.Text.value
      $0.textAlignment = .left
      contentView.addSubview($0)
      
      $0.snp.makeConstraints {
        $0.top.equalTo(titleLabel.snp.bottom).offset(Inset.Padding.extraSmall)
        $0.bottom.equalToSuperview().offset(-Inset.Padding.small)
        $0.leading.equalTo(iconView.snp.trailing).offset(Inset.Padding.default)
        $0.trailing.equalToSuperview().offset(-Inset.Padding.default)
      }
    }
  }
  
  private func createCloseButton() -> UIButton {
    with(UIButton()) {
      contentView.addSubview($0)
      $0.on { [weak self] in self?.onClose?() }
      $0.setImage(
        UIImage(
          systemName: "xmark",
          withConfiguration: UIImage.SymbolConfiguration(pointSize: .zero, weight: .semibold, scale: .small)
        ),
        for: .normal
      )
      $0.layer.cornerRadius = Size.Button.small / 2
      $0.tintColor = Color.Button.gray
      $0.backgroundColor = Color.Background.default
      $0.snp.makeConstraints {
        $0.top.equalToSuperview().offset(Inset.Padding.small)
        $0.trailing.equalToSuperview().offset(-Inset.Padding.small)
        $0.size.equalTo(Size.Button.small)
      }
    }
  }
}
