import UIKit

final class CompositionalLayout: UICollectionViewCompositionalLayout {
  private enum Constants {
    static let backgroundKind = "groupLayoutSectionBackground"
  }
  
  init(
    centersContent: Bool = false,
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
    
    let configuration = UICollectionViewCompositionalLayoutConfiguration()
    configuration.interSectionSpacing = interSectionSpacing
    
    super.init(
      sectionProvider: { index, environment in
        let width = environment.container.effectiveContentSize.width
        let inset = centersContent ? (width - Size.View.contentWidth(for: width)) / 2 : 0
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.leading = inset
        section.contentInsets.trailing = inset
        let backgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: Constants.backgroundKind)
        backgroundDecoration.contentInsets = NSDirectionalEdgeInsets(
          top: .zero,
          leading: inset + Inset.Padding.default,
          bottom: .zero,
          trailing: inset + Inset.Padding.default
        )
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
