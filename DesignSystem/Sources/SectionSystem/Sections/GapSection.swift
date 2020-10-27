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
        return GapSection(color: .background(), size: Observable<CGFloat>(.medium), direction: direction)
    }
    
    public func padding(_ size: CGFloat = .medium,
                        color: UIColor = .clear,
                        direction: GapSection.Direction = .vertical) -> GapSection {
        return GapSection(color: color, size: Observable<CGFloat>(size), direction: direction)
    }
    
    public func padding(multiplier: CGFloat,
                        color: UIColor = .clear,
                        direction: GapSection.Direction = .vertical) -> GapSection {
        return GapSection(color: color, size: Observable<CGFloat>(multiplier), direction: direction, asMultiplier: true)
    }
    
    public func padding(_ size: Observable<CGFloat>,
                        color: UIColor = .clear,
                        direction: GapSection.Direction = .vertical) -> GapSection {
        return GapSection(color: color, size: size, direction: direction)
    }
    
    public func padding(multiplier: Observable<CGFloat>,
                        color: UIColor = .clear,
                        direction: GapSection.Direction = .vertical) -> GapSection {
        return GapSection(color: color, size: multiplier, direction: direction, asMultiplier: true)
    }
}

public class GapSection {
    fileprivate let color: UIColor?
    fileprivate let size: Observable<CGFloat>
    fileprivate let direction: Direction
    fileprivate let asMultiplier: Bool

    public enum Direction {
        case horiztonal, vertical
    }
    
    init(color: UIColor, size: Observable<CGFloat>, direction: Direction, asMultiplier: Bool = false) {
        self.color = color
        self.size = size
        self.direction = direction
        self.asMultiplier = asMultiplier
    }
}

extension GapSection: ViewSection {
    
    public func createView() -> UIView {
        UIView()
    }
    
    public func size(in view: UIView, at index: Int) -> SectionCellSize {
        switch direction {
        case .vertical:
            return SectionCellSize(width: view.bounds.size.width,
                                   height: asMultiplier ? view.bounds.size.height * size.value : size.value)
        case .horiztonal:
            return SectionCellSize(width: asMultiplier ? view.bounds.size.width * size.value : size.value,
                                   height: view.bounds.size.height)
        }
    }
    
    public func configure(_ view: UIView, at index: Int) {
        view.backgroundColor = self.color
    }
}
