//
//  SegmentedOptionsSection.swift
//  SectionSystem
//
//  Created by acantallops on 2019/04/25.
//  Copyright © 2019 Mercari. All rights reserved.
//

import Foundation
import DesignSystem

extension SectionBuilder {
    public func segmentedControl(_ titles: [String], selectedIndex: Observable<Int>) -> SegmentedControlSection {
        return SegmentedControlSection(titles, selectedIndex)
    }
}

public class SegmentedControlSection {
    
    fileprivate let titles: [String]
    fileprivate weak var observedInt: Observable<Int>?
    fileprivate var selfTriggered = false
    
    public init(_ titles: [String], _ observedInt: Observable<Int>) {
        self.titles = titles
        observedInt.addObserver(self) { [weak self] (i) in
            guard let `self` = self else { return }
            guard !self.selfTriggered else { return }
            self.selfTriggered = false
            (self.visibleView as? SegmentedControlView)?.set(selectedIndex: i)
        }
        self.observedInt = observedInt
    }
}

extension SegmentedControlSection: ViewSection, SegmentedControlViewDelegate {

    public var reuseIdentifier: String {
        return "SegmentedControlSection_\(titles.count)"
    }
    
    public func createView() -> UIView {
        return SegmentedControlView()
    }
    
    public func configure(_ view: UIView, at index: Int) {
        (view as? SegmentedControlView)?.set(titles: titles, selectedIndex: observedInt?.value ?? 0, delegate: self)
    }
    
    func selected(_ index: Int) {
        selfTriggered = true
        observedInt?.value = index
    }
}
