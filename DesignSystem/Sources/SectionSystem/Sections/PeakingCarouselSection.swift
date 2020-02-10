//
//  PeakingCarouselSection.swift
//  DesignSystem
//
//  Created by Anthony Smith on 19/01/2020.
//  Copyright © 2020 mercari. All rights reserved.
//

import Foundation

extension SectionBuilder {
    public func peakingCarousel(_ sections: [Section], padding: CGFloat = .keyline) -> PeakingCarouselSection {
        return PeakingCarouselSection(sections, spacing: padding)
    }
}

public class PeakingCarouselSection: SectionBuilder {

    fileprivate let sections: [Section]
    fileprivate let spacing: CGFloat

    public init(_ sections: [Section], spacing: CGFloat) {
        self.sections = sections
        self.spacing = spacing
    }

    private func saltedContentCount() -> Int {
        var count = 0
        for section in sections { count += section.itemCount }
        guard count > 0 else { return 0 }
        return 1 + (count * 2)
    }

    private func unsaltedIndex(from index: Int) -> Int {
        return (index - 1)/2
    }

    // MARK: - Properties

    private lazy var bookendPaddingSection: BedrockSection = {
        let section = padding(self.spacing, direction: .horiztonal)
        return section
    }()

    private lazy var interItemPaddingSection: BedrockSection = {
        let section = padding(self.spacing/2, direction: .horiztonal)
        return section
    }()
}

extension PeakingCarouselSection: NestedSection {
    public var givenSections: [Section] {
        return sections
    }

    public var allSections: [Section] {
        return sections + [bookendPaddingSection, interItemPaddingSection]
    }

    public func section(at index: Int) -> Section {

        if index == 0 || index == saltedContentCount() - 1  {
            return bookendPaddingSection
        }

        if index % 2 != 0 {
            var total = 0
            for section in sections {
                let count = section.itemCount
                if count + total > unsaltedIndex(from: index) { return section }
                total += count
            }
        }

        return interItemPaddingSection
    }

    public var itemCount: Int {
        return self.saltedContentCount()
    }

    public var reuseIdentifiers: [String]  {
        var ids = [bookendPaddingSection.reuseIdentifier, interItemPaddingSection.reuseIdentifier]
        for section in sections {
            if let nestedSection = section as? NestedSection {
                ids.append(contentsOf: nestedSection.reuseIdentifiers)
            } else if let bedrockSection = section as? BedrockSection {
                ids.append(bedrockSection.reuseIdentifier)
            }
        }
        return ids
    }

    public func givenSectionIndex(from index: Int) -> Int? {
        var total = 0
        for section in sections {
            let count = section.itemCount
            let trueIndex = self.unsaltedIndex(from: index)
            if count + total > trueIndex {
                return trueIndex - total
            } else {
                total += count
            }
        }
        return nil
    }
}
