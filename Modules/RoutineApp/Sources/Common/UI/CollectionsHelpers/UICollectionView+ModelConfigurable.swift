import UIKit

extension UICollectionView {
  // MARK: - Public
  func register(_ cellClass: AnyClass) {
    register(cellClass.self, forCellWithReuseIdentifier: identifier(for: cellClass.self))
  }

  func register(_ supplementaryClass: AnyClass, kind: String) {
    register(
      supplementaryClass.self,
      forSupplementaryViewOfKind: kind,
      withReuseIdentifier: identifier(for: supplementaryClass.self)
    )
  }

  func dequeue<Cell: UICollectionViewCell & ModelConfigurable>(
    _ type: Cell.Type,
    with model: Cell.Model,
    for indexPath: IndexPath
  ) -> Cell? {
    guard
      let cell = dequeueReusableCell(withReuseIdentifier: identifier(for: Cell.self), for: indexPath) as? Cell
    else {
      Logger.log(.error, "Failed to cast reuse cell to \(Cell.self)")
      return nil
    }
    
    cell.update(with: model)
    
    return cell
  }
  
  func dequeue<Supplementary: UICollectionReusableView & ModelConfigurable>(
    _ type: Supplementary.Type,
    with model: Supplementary.Model,
    for indexPath: IndexPath,
    kind: String
  ) -> Supplementary? {
    guard
      let supplementary = dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: identifier(for: Supplementary.self),
        for: indexPath
      ) as? Supplementary
    else {
      Logger.log(.error, "Failed to cast reuse supplementary to \(Supplementary.self)")
      return nil
    }
    
    supplementary.update(with: model)
    
    return supplementary
  }
  
  // MARK: - Private
  private func identifier(for class: AnyClass) -> String {
    String(describing: `class`.self)
  }
}
