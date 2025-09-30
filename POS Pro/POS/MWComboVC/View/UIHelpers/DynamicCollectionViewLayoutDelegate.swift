//
//  DynamicCollectionViewLayoutDelegate.swift
//  demo
//
//  Created by DGTERA on 24/07/2024.
//

import UIKit

protocol DynamicCollectionViewLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, displaySizeForItemAt indexPath: IndexPath) -> CGSize
}

