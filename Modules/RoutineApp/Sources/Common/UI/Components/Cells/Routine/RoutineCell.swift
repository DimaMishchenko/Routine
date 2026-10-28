import SnapKit
import SwipeCellKit
import UIKit

final class RoutineCell: SwipeCollectionViewCell, ModelConfigurable {
  var onEdit: (() -> Void)?
  var onDelete: (() -> Void)?
  var onIncrease: (() -> Void)?
  var onDecrease: (() -> Void)?
  
  private lazy var containerView = createContainerView()
  private lazy var emojiLabel = createEmojiLabel()
  private lazy var titleLabel = createTitleLabel()
  private lazy var goalLabel = createGoalLabel()
  private lazy var undoButton = createUndoButton()
  private lazy var progress = createProgress()
  private lazy var progressTapGesture = UITapGestureRecognizer(target: self, action: #selector(increaseProgress))
  
  private var updateInProgress = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    delegate = self
    updateBackgroundConfiguration()
    isAccessibilityElement = true
    accessibilityTraits = .button
    accessibilityCustomActions = [
      UIAccessibilityCustomAction(
        name: RoutineAppStrings.Localizable.RoutineList.Action.increaseProgress,
        target: self,
        selector: #selector(accessibilityIncreaseProgress)
      ),
      UIAccessibilityCustomAction(
        name: RoutineAppStrings.Localizable.RoutineList.Action.decreaseProgress,
        target: self,
        selector: #selector(accessibilityDecreaseProgress)
      ),
      UIAccessibilityCustomAction(
        name: RoutineAppStrings.Localizable.NavBar.edit,
        target: self,
        selector: #selector(accessibilityEdit)
      ),
      UIAccessibilityCustomAction(
        name: RoutineAppStrings.Localizable.RoutineEdit.Button.delete,
        target: self,
        selector: #selector(accessibilityDelete)
      )
    ]
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(with model: RoutineCellVM) {
    emojiLabel.text = model.emoji
    titleLabel.text = model.title
    goalLabel.text = model.goal
    accessibilityLabel = "\(model.emoji) \(model.title)"
    accessibilityValue = model.goal
    progress.update(progress: model.progressPercent, animated: false)
  }
  
  func updateProgress(to newValue: Double, completion: @escaping () -> Void) {
    updateInProgress = true
    progress.update(progress: newValue, animated: true) { [weak self] in
      self?.updateInProgress = false
      completion()
    }
  }
}

extension RoutineCell: SwipeCollectionViewCellDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    editActionsForItemAt indexPath: IndexPath,
    for orientation: SwipeActionsOrientation
  ) -> [SwipeAction]? {
    let action = SwipeAction(style: .default, title: nil) { [weak self] _, _ in
      switch orientation {
      case .right: self?.onDelete?()
      case .left: self?.onEdit?()
      }
    }
    
    action.backgroundColor = .clear
    let image: UIImage = {
      switch orientation {
      case .right: return RoutineAppAsset.Icon.delete.image
      case .left: return RoutineAppAsset.Icon.edit.image
      }
    }()
    action.image = image
    action.highlightedImage = image.alpha(0.7)
    
    return [action]
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    editActionsOptionsForItemAt indexPath: IndexPath,
    for orientation: SwipeActionsOrientation
  ) -> SwipeOptions {
    with(SwipeOptions()) {
      $0.backgroundColor = Color.Background.default
      $0.buttonVerticalAlignment = .center
    }
  }
}

extension RoutineCell {
  @objc private func increaseProgress() {
    guard !updateInProgress else { return }
    onIncrease?()
  }

  @objc private func accessibilityIncreaseProgress() -> Bool {
    guard !updateInProgress else { return false }
    onIncrease?()
    return true
  }

  @objc private func accessibilityDecreaseProgress() -> Bool {
    guard !updateInProgress else { return false }
    onDecrease?()
    return true
  }

  @objc private func accessibilityEdit() -> Bool {
    onEdit?()
    return true
  }

  @objc private func accessibilityDelete() -> Bool {
    onDelete?()
    return true
  }
}
  
extension RoutineCell {
  private func updateBackgroundConfiguration() {
    backgroundConfiguration = .clear()
  }
  
  private func createContainerView() -> UIView {
    with(UIView()) {
      $0.layer.cornerRadius = Size.CornerRadius.container
      $0.backgroundColor = Color.Background.secondary
      contentView.addSubview($0)
      
      $0.snp.makeConstraints {
        $0.edges.equalToSuperview()
        $0.height.greaterThanOrEqualTo(72)
      }
    }
  }
  
  private func createEmojiLabel() -> UILabel {
    with(UILabel()) {
      $0.font = Font.system(.body, weight: .regular)
      $0.adjustsFontForContentSizeCategory = true
      $0.adjustsFontSizeToFitWidth = true
      $0.minimumScaleFactor = 0.3
      $0.textAlignment = .natural
      containerView.addSubview($0)
      
      $0.snp.makeConstraints {
        $0.top.equalToSuperview().offset(Inset.Padding.small)
        $0.leading.equalToSuperview().offset(Inset.Padding.default)
        $0.size.equalTo(Size.Button.small)
      }
    }
  }
  
  private func createTitleLabel() -> UILabel {
    with(UILabel()) {
      $0.font = Font.system(.title3, weight: .semibold)
      $0.adjustsFontForContentSizeCategory = true
      $0.numberOfLines = .zero
      $0.textColor = Color.Text.default
      $0.textAlignment = .natural
      containerView.addSubview($0)
      
      $0.snp.makeConstraints {
        $0.leading.equalTo(emojiLabel.snp.trailing).offset(Inset.Padding.small)
        $0.trailing.lessThanOrEqualTo(undoButton.snp.leading)
        $0.top.equalTo(emojiLabel)
        $0.height.greaterThanOrEqualTo(Size.Button.small)
      }
    }
  }
  
  private func createGoalLabel() -> UILabel {
    with(UILabel()) {
      $0.font = Font.system(.footnote, weight: .semibold)
      $0.adjustsFontForContentSizeCategory = true
      $0.numberOfLines = .zero
      $0.textAlignment = .natural
      $0.textColor = Color.Text.value
      containerView.addSubview($0)
      
      $0.snp.makeConstraints {
        $0.top.equalTo(titleLabel.snp.bottom).offset(Inset.Padding.small)
        $0.leading.equalToSuperview().offset(Inset.Padding.default)
        $0.trailing.lessThanOrEqualTo(undoButton.snp.leading)
        $0.bottom.equalToSuperview().offset(-Inset.Padding.small)
      }
    }
  }
  
  private func createUndoButton() -> UIButton {
    with(UIButton(type: .system)) {
      $0.on { [weak self] in
        guard self?.updateInProgress == false else { return }
        self?.onDecrease?()
      }
      $0.setImage(RoutineAppAsset.Icon.undo.image, for: .normal)
      $0.imageEdgeInsets = UIEdgeInsets(
        top: Inset.Padding.small,
        left: .zero,
        bottom: .zero,
        right: .zero
      )
      
      containerView.addSubview($0)

      $0.snp.makeConstraints {
        $0.centerY.equalToSuperview()
        $0.size.equalTo(Size.Button.default)
        $0.trailing.equalTo(progress.snp.leading)
      }
    }
  }
  
  private func createProgress() -> RountineProgress {
    with(RountineProgress()) {
      containerView.addSubview($0)
      $0.addGestureRecognizer(progressTapGesture)
      $0.snp.makeConstraints {
        $0.centerY.equalToSuperview()
        $0.trailing.equalToSuperview().offset(-Inset.Padding.default)
        $0.size.equalTo(54)
      }
    }
  }
}
