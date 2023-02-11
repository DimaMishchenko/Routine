import PinLayout
import UIKit

final class SettingsView: UIView {
  // MARK: - Public Properties
  var onNotificationStateChangeRequest: ((Bool) -> Void)?
  var onFaceIDStateChangeRequest: ((Bool) -> Void)?
  
  // MARK: - Private Properties
  private var initialLayout = Once()
  
  // MARK: - UI Properties
  private lazy var collectionView = createCollectionView()
  private lazy var dataSource = createDataSource()
  
  // MARK: - Override
  override func layoutSubviews() {
    super.layoutSubviews()
    initialLayout.once { setupUI() }
    updateLayout()
  }
}

// MARK: - Public
extension SettingsView {
  func update(with snapshot: Snapshot<Settings.Section, Settings.Row>) {
    dataSource.apply(snapshot)
  }
}

// MARK: - UICollectionViewDelegate
extension SettingsView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    dataSource.row(at: indexPath).action?()
    collectionView.deselectItem(at: indexPath, animated: true)
  }
}

// MARK: - Private
extension SettingsView {
  private func setupUI() {
    backgroundColor = Color.Background.default
  }
  
  private func updateLayout() {
    collectionView.pin.all()
  }
  
  private func createDataSource() -> DataSource<Settings.Section, Settings.Row> {
    let dataSource = DataSource<Settings.Section, Settings.Row>(
      collectionView: collectionView
    ) { collectionView, indexPath, row -> UICollectionViewCell? in
      switch row.type {
      case .value(let viewModel):
        return collectionView.dequeue(ValueCell.self, with: viewModel, for: indexPath)
      case let .switch(viewModel, type):
        return collectionView.dequeue(SwitchCell.self, with: viewModel, for: indexPath) {
          switch type {
          case .notifications:
            $0.onChangeRequest = { [weak self] in self?.onNotificationStateChangeRequest?($0) }
          case .faceID:
            $0.onChangeRequest = { [weak self] in self?.onFaceIDStateChangeRequest?($0) }
          }
        }
      }
    }
    
    dataSource.supplementaryViewProvider = { [weak dataSource] collectionView, kind, indexPath in
      guard
        kind == UICollectionView.elementKindSectionHeader,
        let model = dataSource?.section(at: indexPath.section).model
      else { return nil }
      
      return collectionView.dequeue(GroupSupplementary.self, with: model, for: indexPath, kind: kind)
    }
    
    return dataSource
  }
  
  private func createCollectionView() -> UICollectionView {
    let configuration = with(UICollectionLayoutListConfiguration(appearance: .insetGrouped)) {
      $0.backgroundColor = Color.Background.default
      $0.headerMode = .supplementary
      if #available(iOS 14.5, *) {
        $0.separatorConfiguration.bottomSeparatorInsets = .init(top: .zero, leading: 62, bottom: .zero, trailing: .zero)
      }
    }
    
    return with(UICollectionView(layout: .list(using: configuration))) {
      $0.delegate = self
      $0.register(GroupSupplementary.self, kind: UICollectionView.elementKindSectionHeader)
      $0.register(ValueCell.self)
      $0.register(SwitchCell.self)
      addSubview($0)
    }
  }
}
