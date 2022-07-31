import PinLayout
import UIKit

final class RoutineListView: UIView {
  // MARK: - Private Properties
  private var initialLayout = Once()
  
  // MARK: - Public Properties
  var onAdd: (() -> Void)?
  
  var onEdit: ((RoutineList.Section, Int) -> Void)?
  var onDelete: ((RoutineList.Section, Int) -> Void)?
  var onIncreaseProgress: ((RoutineList.Section, Int) -> Void)?
  var onDecreaseProgress: ((RoutineList.Section, Int) -> Void)?
  
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
  func update(
    with snapshot: Snapshot<RoutineList.Section, OutlineItem<RoutineList.Header, RoutineList.Row>>,
    animated: Bool
  ) {
    dataSource.apply(snapshot, animatingDifferences: animated)
  }
  
  func animateProgressUpdate(
    for newValue: Double,
    at indexPath: IndexPath,
    completion: @escaping () -> Void
  ) {
    // +1 because of outline cell
    let indexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
    guard let cell = collectionView.cellForItem(at: indexPath) as? RoutineCell else { return }
    cell.updateProgress(to: newValue) { completion() }
  }
}

// MARK: - UICollectionViewDelegate
extension RoutineListView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if case .row(let row) = dataSource.row(at: indexPath) {
      row.action?()
    }
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
      .size(Size.Button.default)
      .bottom(pin.safeArea)
      .right(pin.safeArea)
      .margin(Inset.Padding.default)
  }
  
  private func position(for cell: UICollectionViewCell?) -> (section: RoutineList.Section, row: Int)? {
    guard
      let cell = cell,
      let indexPath = collectionView.indexPath(for: cell)
    else {
      return nil
    }
    
    let section = dataSource.section(at: indexPath.section)
    return (section, indexPath.row - 1) // -1 because of outline cell
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
        case .routine(let viewModel):
          let cell = collectionView.dequeue(RoutineCell.self, with: viewModel, for: indexPath)
          
          cell?.onEdit = { [weak self, weak cell] in
            guard let position = self?.position(for: cell) else { return }
            self?.onEdit?(position.section, position.row)
          }
          
          cell?.onDelete = { [weak self, weak cell] in
            guard let position = self?.position(for: cell) else { return }
            self?.onDelete?(position.section, position.row)
          }
          
          cell?.onIncrease = { [weak self, weak cell] in
            guard let position = self?.position(for: cell) else { return }
            self?.onIncreaseProgress?(position.section, position.row)
          }
          
          cell?.onDecrease = { [weak self, weak cell] in
            guard let position = self?.position(for: cell) else { return }
            self?.onDecreaseProgress?(position.section, position.row)
          }
          return cell
        }
      }
    }
    
    dataSource.sectionSnapshotHandlers.willExpandItem = { _ in HapticFeedback.select() }
    dataSource.sectionSnapshotHandlers.willCollapseItem = { _ in HapticFeedback.select() }
    
    return dataSource
  }
  
  private func createCollectionView() -> UICollectionView {
    let layout = CompositionalLayout(
      itemContentInset: NSDirectionalEdgeInsets(
        top: .zero,
        leading: Inset.Padding.default,
        bottom: .zero,
        // TODO: - IOS 15.3 bug
        trailing: Inset.Padding.default
      ),
      itemEdgeSpacing: NSCollectionLayoutEdgeSpacing(
        leading: nil,
        top: .fixed(Inset.Padding.small),
        trailing: nil,
        bottom: nil
      ),
      interSectionSpacing: Inset.Padding.small,
      applyGroupBackground: { _ in false }
    )
    
    return with(UICollectionView(layout: layout)) {
      $0.delegate = self
      $0.backgroundColor = .clear
      $0.delaysContentTouches = false
      $0.register(EmptyCell.self)
      $0.register(RoutineCell.self)
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
