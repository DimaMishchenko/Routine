import UIKit

extension UICollectionView {
  convenience init(layout: UICollectionViewCompositionalLayout) {
    self.init(frame: .zero, collectionViewLayout: layout)
  }
}
