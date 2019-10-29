//
//  CarouselViewModel.swift
//  SectionSystem
//
//  Created by anthony on 26/11/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation

extension SectionBuilder {
    public func carousel(_ reuseIdentifier: String = UUID().uuidString, height: CarouselSection.HeightType = .full, pagingEnabled: Bool = false, sections: @autoclosure @escaping () -> [Section]) -> CarouselSection {
        return CarouselSection(id: reuseIdentifier, heightType: height, pagingEnabled: pagingEnabled, sectionsClosure: sections)
    }
}

public class CarouselSection {

    public enum HeightType {
        case full, multiplier(CGFloat), custom(CGFloat)
    }
    
    private let id: String
    private let heightType: HeightType
    private let pagingEnabled: Bool
    private let sectionsClosure: () -> [Section]
    private var staticSections: [Section]

    fileprivate init(id: String, heightType: HeightType, pagingEnabled: Bool, sectionsClosure: @escaping () -> [Section]) {
        self.id = id
        self.heightType = heightType
        self.pagingEnabled = pagingEnabled
        self.sectionsClosure = sectionsClosure
        self.staticSections = sectionsClosure()
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
        return CarouselViewController()
    }

    public func size(in view: UIView, at index: Int) -> SectionCellSize {
        
        switch heightType {
        case .full:
            return SectionCellSize(width: view.bounds.size.width, height: view.bounds.size.height)
        case .custom(let value):
            return SectionCellSize(width: view.bounds.size.width, height: value)
        case .multiplier(let value):
            return SectionCellSize(width: view.bounds.size.width, height: view.bounds.size.height * value)
        }
    }

    public func configure(_ viewController: UIViewController, at index: Int) {

        guard let vc = viewController as? CarouselViewController else { return }
        vc.collectionView.isPagingEnabled = self.pagingEnabled
        vc.dataSource.sections = staticSections
        vc.reload()
        
        // move offset logic into section collectionviewcontroller
        // vc.collectionView.setContentOffset(CGPoint(x: vc.collectionView.contentSize.width > self.dataSource.offset ? self.dataSource.offset : 0.0, y: 0.0), animated: false)
    }
}
