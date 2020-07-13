//
//  CollectionViewCell.swift
//  SectionSystem
//
//  Created by Anthony Smith on 11/09/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation
import UIKit

public class SectionCollectionViewCell: UICollectionViewCell {

    public internal(set) weak var section: BedrockSection?
    public internal(set) weak var sectionView: UIView?
    public internal(set) weak var sectionViewController: UIViewController?
    public internal(set) var indexPath: IndexPath?

    override public func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {

        let size: SectionCellSize

        if let section = section, let indexPath = indexPath {
            size = section.size(in: self.superview ?? self, at: indexPath.item)
        } else {
            size = .automatic
        }

        // The 1.0 here just needs to be bigger than zero
        // .defaultLow will override with the automatic size for us
        let newSize = CGSize(width: size.width ?? 1.0, height: size.height ?? 1.0)
        var newFrame = layoutAttributes.frame
        newFrame.size = newSize
        layoutAttributes.frame = newFrame
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(newSize,
                                                                          withHorizontalFittingPriority: size.width == nil ? .defaultLow : .required,
                                                                          verticalFittingPriority: size.height == nil ? .defaultLow : .required)
        return layoutAttributes
    }

    override public var isHighlighted: Bool { didSet { (sectionView as? Highlightable)?.set(for: isHighlighted, selected: isSelected) } }
    override public var isSelected: Bool { didSet { (sectionView as? Highlightable)?.set(for: isHighlighted, selected: isSelected) } }
}
