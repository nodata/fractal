//
//  CarouselViewModel.swift
//  SectionSystem
//
//  Created by anthony on 26/11/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation
import UIKit

extension SectionBuilder {
    public func carousel(_ reuseIdentifier: String = UUID().uuidString,
                         height: CarouselSection.HeightType = .full,
                         pagingType: CarouselViewController.PagingType = .false,
                         backgroundColor: UIColor = .clear,
                         layout: UICollectionViewLayout? = nil,
                         didScrollClosure: ((UIScrollView) -> Void)? = nil,
                         sections: @autoclosure @escaping () -> [Section]) -> CarouselSection {
        return CarouselSection(id: reuseIdentifier,
                               heightType: height,
                               pagingType: pagingType,
                               backgroundColor: backgroundColor,
                               layout: layout,
                               didScrollClosure: didScrollClosure,
                               sectionsClosure: sections)
    }
}

public class CarouselSection {

    public enum PositionType {
        case left, right, center, top, bottom
        
        func point(in collectionView: UICollectionView) -> CGPoint {
            
            let point: CGPoint
            
            switch self {
            case .left:
                point = CGPoint(x: 1.0, y: collectionView.bounds.size.height/2)
            case .right:
                point = CGPoint(x: collectionView.bounds.size.width-1.0, y: collectionView.bounds.size.height/2)
            case .center:
                point = CGPoint(x: collectionView.bounds.size.width/2, y: collectionView.bounds.size.height/2)
            case .top:
                point = CGPoint(x: collectionView.bounds.size.width/2, y: 1.0)
            case .bottom:
                point = CGPoint(x: collectionView.bounds.size.width/2, y: collectionView.bounds.size.height - 1.0)
            }
            
            return CGPoint(x: collectionView.contentOffset.x + point.x, y: collectionView.contentOffset.y + point.y)
        }
        
        var modifier: Int {
            switch self {
            case .left, .top:
                return -1
            case .right, .bottom:
                return 1
            case .center:
                return 0
            }
        }
    }

    public enum HeightType {
        case full, width, multiplier(CGFloat), custom(CGFloat)
    }
    
    private let id: String
    private let heightType: HeightType
    private let pagingType: CarouselViewController.PagingType
    private let sectionsClosure: () -> [Section]
    private var staticSections: [Section]
    private let layout: UICollectionViewLayout?
    private var didScrollClosure: ((UIScrollView) -> Void)?
    private let backgroundColor: UIColor
    
    fileprivate init(id: String,
                     heightType: HeightType,
                     pagingType: CarouselViewController.PagingType,
                     backgroundColor: UIColor,
                     layout: UICollectionViewLayout?,
                     didScrollClosure: ((UIScrollView) -> Void)?,
                     sectionsClosure: @escaping () -> [Section]) {
        self.id = id
        self.heightType = heightType
        self.pagingType = pagingType
        self.backgroundColor = backgroundColor
        self.sectionsClosure = sectionsClosure
        self.staticSections = sectionsClosure()
        self.didScrollClosure = didScrollClosure
        self.layout = layout
    }
    
    public func currentIndexPath(at position: PositionType) -> IndexPath? {
        guard let vc = visibleViewController as? CarouselViewController else { return nil }
        guard let indexPath = vc.collectionView.indexPathForItem(at: position.point(in: vc.collectionView)) else { return nil }
        
        // This won't work out of the box for peaking carousels as the gaps will count as indexes
        if pagingType == .calculatedDoubleJump && indexPath.item % 2 != 0 {
            // TODO: untested
            return IndexPath(item: indexPath.item + position.modifier, section: indexPath.section)
        }
        
        return indexPath
    }
    
    public func scroll(to indexPath: IndexPath, animated: Bool) {
        guard let vc = visibleViewController as? CarouselViewController else { return }
        vc.collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally, .centeredVertically], animated: animated)
    }
    
    public var sections: [Section] {
        guard let vc = visibleViewController as? CarouselViewController else { return [] }
        return vc.dataSource.sections
    }
}

extension CarouselSection: ViewControllerSection {

    // We could reuse here... not 100% sure how yet other than
    // A: let developers override the carousel id / manually handle (current option)
    // B: or by the type of cells it holds (potentially messy as might need other properties to be captured)
    // C: Let all reload and eventually capture all the reuseIdentifiers they need (any value?)
    
    public var reuseIdentifier: String {
        return "Carousel_\(id)"
    }

    public func willReload() {
        staticSections = sectionsClosure()
    }
    
    public func createViewController() -> UIViewController {
        let vc = CarouselViewController()
        vc.didScrollClosure = didScrollClosure
        return vc
    }

    public func size(in view: UIView, at index: Int) -> SectionCellSize {

        let width = view.bounds.size.width
        switch heightType {
        case .full:
            return SectionCellSize(width: width, height: view.bounds.size.height)
        case .width:
            return SectionCellSize(width: width, height: width)
        case .custom(let value):
            return SectionCellSize(width: width, height: value)
        case .multiplier(let value):
            return SectionCellSize(width: width, height: view.bounds.size.height * value)
        }
    }

    public func configure(_ viewController: UIViewController, at index: Int) {

        guard let vc = viewController as? CarouselViewController else { return }
        vc.pagingType = pagingType
        vc.dataSource.sections = staticSections
        vc.view.backgroundColor = backgroundColor
        vc.reload()
        
        // move offset logic into section collectionviewcontroller
        // vc.collectionView.setContentOffset(CGPoint(x: vc.collectionView.contentSize.width > self.dataSource.offset ? self.dataSource.offset : 0.0, y: 0.0), animated: false)
    }
}

extension CarouselSection {
    public static func cardPagingClosure(with viewControllerSection: ViewControllerSection, showTopBorder: Bool = true) -> (UIScrollView) -> Void {
        return { [unowned viewControllerSection] scrollView in
            for vc in viewControllerSection.visibleViewControllers {
                guard scrollView.isBeingManipulated else { return }
                let position = vc.view.convert(vc.view.frame.origin, to: nil)
                let percentage = position.x / scrollView.bounds.size.width
                let absPercentage = abs(position.x) / scrollView.bounds.size.width
                let excelPercentage = min(absPercentage * 10.0, 1.0)
                let scale = 1.0 - (0.05 * absPercentage)
                let dividerWidth: CGFloat = CGFloat.divider < 1.0 ? 1.0 : .divider
                var transform = CGAffineTransform(scaleX: scale, y: scale)
                transform = transform.rotated(by: (CGFloat.pi/100) * percentage)
                vc.view.transform = transform
                vc.view.layer.borderWidth = dividerWidth * excelPercentage
                vc.view.layer.cornerRadius = .mediumCornerRadius * excelPercentage
            }
            
            guard showTopBorder else { return }
            guard let vc = viewControllerSection.visibleViewControllers.first else { return }
            guard let parent = vc.parent else { return }
            
            if let c = vc.view.layer.borderColor {
                if !(parent.view.layer.borderColor?.equals(c) ?? true) { parent.view.layer.borderColor = c }
            }
            
            let amount = abs(scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.bounds.size.width))
            if amount < 10.0 {
                parent.view.layer.borderWidth = amount / 10.0
            } else if amount > (scrollView.bounds.size.width - 10.0) {
                parent.view.layer.borderWidth = (scrollView.bounds.size.width - amount) / 10.0
            } else {
                parent.view.layer.borderWidth = 1.0
            }
        }
    }
    
    public static func reset(_ viewController: UIViewController) {
        viewController.view.transform = .identity
        viewController.view.layer.borderWidth = 0.0
        viewController.view.layer.cornerRadius = 0.0
    }
}
