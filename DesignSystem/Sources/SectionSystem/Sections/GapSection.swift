//
//  GapSection.swift
//  Fractal
//
//  Created by Anthony Smith on 18/06/2019.
//  Copyright © 2019 nodata. All rights reserved.
//

import Foundation

extension SectionBuilder {
    public func seperator(_ direction: GapSection.Direction = .vertical) -> GapSection {
        return GapSection(color: .background(), size: .medium, direction: direction)
    }
    
    // Workaround to avoid to be detected as a leak when using system static UIColors
    public func padding(_ size: CGFloat = .medium,
                        color: UIColor = .init(red: 0, green: 0, blue: 0, alpha: 0),
                        direction: GapSection.Direction = .vertical) -> GapSection {
        return GapSection(color: color, size: size, direction: direction)
    }
}

public class GapSection {
    fileprivate let color: UIColor?
    fileprivate let size: CGFloat
    fileprivate let direction: Direction

    public enum Direction {
        case horiztonal, vertical
    }
    
    init(color: UIColor, size: CGFloat, direction: Direction) {
        self.color = color
        self.size = size
        self.direction = direction
    }
}

extension GapSection: ViewSection {
    
    public func createView() -> UIView {
        return UIView()
    }
    
    public func size(in view: UIView, at index: Int) -> SectionCellSize {
        switch direction {
        case .vertical:
            return SectionCellSize(width: view.bounds.size.width, height: self.size)
        case .horiztonal:
            return SectionCellSize(width: self.size, height: view.bounds.size.height)
        }
    }
    
    public func configure(_ view: UIView, at index: Int) {
        view.backgroundColor = self.color
    }
}
