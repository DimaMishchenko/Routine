import PinLayout
import UIKit

final class RoutineListView: UIView {
  private var initialLayout = Once()
  var onEdit: ((RoutineList.Section, Int) -> Void)?
  var onDelete: ((RoutineList.Section, Int) -> Void)?
  var onIncreaseProgress: ((RoutineList.Section, Int) -> Void)?
  var onDecreaseProgress: ((RoutineList.Section, Int) -> Void)?
  private lazy var collectionView = createCollectionView()
  private lazy var dataSource = createDataSource()
  override func layoutSubviews() {
    super.layoutSubviews()
    initialLayout.once { setupUI() }
    updateLayout()
  }
}
extension RoutineListView {
  func update(
    with snapshot: Snapshot<RoutineList.Section, OutlineItem<RoutineList.Header, RoutineList.Row>>,
    animated: Bool
  ) {
    dataSource.apply(snapshot, animatingDifferences: animated)
  }
  
  func animateProgressUpdate(
    for viewModel: RoutineCellVM,
    at indexPath: IndexPath,
    completion: @escaping () -> Void
  ) {
    let indexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
    guard let cell = collectionView.cellForItem(at: indexPath) as? RoutineCell else {
      completion()
      return
    }
    cell.updateProgress(to: viewModel.progressPercent) { [weak self] in
      guard
        let self = self,
        let currentItem = self.dataSource.itemIdentifier(for: indexPath),
        case .row(let row) = currentItem
      else {
        completion()
        return
      }
      
      var snapshot = self.dataSource.snapshot()
      snapshot.insertItems([.row(RoutineList.Row(.routine(viewModel), action: row.action))], afterItem: currentItem)
      snapshot.deleteItems([currentItem])
      self.dataSource.apply(snapshot, animatingDifferences: false)
      
      completion()
    }
  }
}
extension RoutineListView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if case .row(let row) = dataSource.row(at: indexPath) {
      row.action?()
    }
    collectionView.deselectItem(at: indexPath, animated: true)
  }
}
extension RoutineListView {
  private func setupUI() {
    backgroundColor = Color.Background.default
  }
  
  private func updateLayout() {
    collectionView.pin.all()
  }
  
  private func position(for cell: UICollectionViewCell?) -> (section: RoutineList.Section, row: Int)? {
    guard
      let cell = cell,
      let indexPath = collectionView.indexPath(for: cell)
    else {
      return nil
    }
    
    let section = dataSource.section(at: indexPath.section)
    return (section, indexPath.row - 1)
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
          return collectionView.dequeue(RoutineCell.self, with: viewModel, for: indexPath) { cell in
            cell.onEdit = { [weak self, weak cell] in
              guard let position = self?.position(for: cell) else { return }
              self?.onEdit?(position.section, position.row)
            }
            cell.onDelete = { [weak self, weak cell] in
              guard let position = self?.position(for: cell) else { return }
              self?.onDelete?(position.section, position.row)
            }
            cell.onIncrease = { [weak self, weak cell] in
              guard let position = self?.position(for: cell) else { return }
              self?.onIncreaseProgress?(position.section, position.row)
            }
            cell.onDecrease = { [weak self, weak cell] in
              guard let position = self?.position(for: cell) else { return }
              self?.onDecreaseProgress?(position.section, position.row)
            }
          }
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
}
