import PinLayout
import UIKit

final class RoutineListView: UIView {
  // MARK: - Private Properties
  private var initialLayout = Once()
  
  // MARK: - Public Properties
  var onAdd: (() -> Void)?
  
  // MARK: - UI Properties
  private lazy var collectionView = createCollectionView()
  private lazy var dataSource = createDataSource()
  private lazy var addButton = createAddButton()
  
  // MARK: - Override
  override func layoutSubviews() {
    super.layoutSubviews()
    initialLayout.once { setupUI() }
    updateLayout()
  }
}

// MARK: - Public
extension RoutineListView {
  func update(with snapshot: Snapshot<RoutineList.Section, OutlineItem<RoutineList.Header, RoutineList.Row>>) {
    dataSource.apply(snapshot)
  }
}

// MARK: - UICollectionViewDelegate
extension RoutineListView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    dataSource.row(at: indexPath).action?()
    collectionView.deselectItem(at: indexPath, animated: true)
  }
}

// MARK: - Private
extension RoutineListView {
  private func setupUI() {
    backgroundColor = Color.Background.default
  }
  
  private func updateLayout() {
    collectionView.pin.all()
    addButton.pin
      .size(CGSize(width: 44, height: 44))
      .bottom(pin.safeArea)
      .right(pin.safeArea)
      .margin(Inset.Padding.default)
  }
  
  private func createDataSource() -> OutlineDataSource<RoutineList.Section, RoutineList.Header, RoutineList.Row> {
    let dataSource = OutlineDataSource<RoutineList.Section, RoutineList.Header, RoutineList.Row>(
      collectionView: collectionView
    ) { collectionView, indexPath, row -> UICollectionViewCell? in
      switch row {
      case .header(let header):
        return collectionView.dequeue(GroupSupplementary.self, with: header.model, for: indexPath)
      case .row(let row):
        switch row.type {
        case .empty(let viewModel):
          return collectionView.dequeue(EmptyCell.self, with: viewModel, for: indexPath)
        }
      }
    }
    
    return dataSource
  }
  
  private func createCollectionView() -> UICollectionView {
    let configuration = with(UICollectionLayoutListConfiguration(appearance: .sidebar)) {
      $0.backgroundColor = Color.Background.default
    }
    
    return with(UICollectionView(layout: .list(using: configuration))) {
      $0.delegate = self
      $0.register(EmptyCell.self)
      $0.register(GroupSupplementary.self)
      addSubview($0)
    }
  }
  
  private func createAddButton() -> UIButton {
    with(UIButton()) {
      addSubview($0)
      $0.setImage(RoutineAppAsset.Icon.add.image, for: .normal)
      $0.on { [weak self] in self?.onAdd?() }
    }
  }
}
