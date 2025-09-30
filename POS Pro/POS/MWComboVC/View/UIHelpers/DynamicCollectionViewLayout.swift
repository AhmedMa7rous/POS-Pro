//
//  DynamicCollectionViewLayout.swift
//  demo
//
//  Created by DGTERA on 24/07/2024.
//

import UIKit

class DynamicCollectionViewLayout: UICollectionViewLayout {
    weak var delegate: DynamicCollectionViewLayoutDelegate?
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    private var interItemSpacing: CGFloat = 20

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        guard let collectionView = collectionView else { return }

        // Clear cache and reset content height
        cache.removeAll()
        contentHeight = 0

        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0

        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            
            // Calculate the item's size based on its content
            if let itemSize = delegate?.collectionView(collectionView, displaySizeForItemAt: indexPath) {
                let frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height)
                let insetFrame = frame.insetBy(dx: 0, dy: 0)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetFrame
                cache.append(attributes)
                
                contentHeight = 70
                
                xOffset = xOffset + itemSize.width + interItemSpacing
                if xOffset + itemSize.width > contentWidth {
                    xOffset = 0
                    yOffset += itemSize.height + interItemSpacing
                }
            }
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}

