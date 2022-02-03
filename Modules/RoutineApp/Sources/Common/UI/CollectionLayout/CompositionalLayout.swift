import UIKit

final class CompositionalLayout: UICollectionViewCompositionalLayout {
  // MARK: - Constants
  private enum Constants {
    static let backgroundKind = "groupLayoutSectionBackground"
  }
  
  // MARK: - Init
  init(
    itemContentInset: NSDirectionalEdgeInsets = .zero,
    itemEdgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
    interSectionSpacing: CGFloat = Inset.Padding.default,
    applyGroupBackground: @escaping (Int) -> Bool = { _ in true },
    supplementaryItems: @escaping (Int) -> [NSCollectionLayoutBoundarySupplementaryItem] = { _ in [] }
  ) {
    let item = NSCollectionLayoutItem(
      layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(Size.View.cellDefault))
    )
    item.contentInsets = itemContentInset
    item.edgeSpacing = itemEdgeSpacing
    
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(Size.View.cellDefault)),
      subitems: [item]
    )
    
    let backgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: Constants.backgroundKind)
    backgroundDecoration.contentInsets = NSDirectionalEdgeInsets(
      top: .zero,
      leading: Inset.Padding.default,
      bottom: .zero,
      trailing: Inset.Padding.default
    )
    
    let configuration = UICollectionViewCompositionalLayoutConfiguration()
    configuration.interSectionSpacing = interSectionSpacing
    
    super.init(
      sectionProvider: { index, _ in
        let section = NSCollectionLayoutSection(group: group)
        section.decorationItems = applyGroupBackground(index) ? [backgroundDecoration] : []
        section.boundarySupplementaryItems = supplementaryItems(index)
        return section
      },
      configuration: configuration
    )
    register(GroupBackgroundView.self, forDecorationViewOfKind: Constants.backgroundKind)
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
