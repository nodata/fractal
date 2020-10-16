//
//  GroupSection.swift
//  SectionSystem
//
//  Created by anthony on 19/11/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation

extension SectionBuilder {
    public func group(_ sections: [Section], middleDivider: BedrockSection? = nil, bookends: GroupSection.BookendType = .both) -> GroupSection {
        return GroupSection(sections, middleDivider: middleDivider, bookends: bookends)
    }
}

public class GroupSection: SectionBuilder {

    // NOTE: SectionInsets, minimumInteritemSpacing, minimumLineSpacing inside a group is not supported.
    // They will default to zero for all values

    public enum BookendType {
        case none, both, top, bottom
    }
    
    fileprivate let sections: [Section]
    fileprivate let middleDivider: BedrockSection?
    fileprivate let bookends: BookendType

    public init(_ sections: [Section], middleDivider: BedrockSection?, bookends: BookendType) {
        self.sections = sections
        self.middleDivider = middleDivider
        self.bookends = bookends
    }

    private func saltedContentCount() -> Int {
        var count = 0
        for section in sections { count += section.itemCount }
        guard count > 0 else { return 0 }
        
        var final = (count * 2) - 1
        
        switch bookends {
        case .none:
            break
        case .both:
            final += 2
        case .top, .bottom:
            final += 1
        }

        return final//bookends ? 1 + (count * 2) : (count * 2) - 1
    }

    private func unsaltedIndex(from index: Int) -> Int {
        switch bookends {
        case .none:
            return index/2
        case .both:
            return (index - 1)/2
        case .top:
            return (index - 1)/2
        case .bottom:
            return index/2
        }
    }

    // MARK: - Properties

    private lazy var bookendTopDivider: BedrockSection = {
        let dividerSection = divider(.full)
        return dividerSection
    }()

    private lazy var bookendBottomDivider: BedrockSection = {
        let dividerSection = divider(.full)
        return dividerSection
    }()

    private lazy var defaultMiddleDivider: BedrockSection = {
        let dividerSection = divider(.indented(.keyline))
        return dividerSection
    }()
}

extension GroupSection: NestedSection {
    public var givenSections: [Section] {
        return sections
    }

    public var allSections: [Section] {
        return sections + [bookendTopDivider, bookendBottomDivider, (middleDivider ?? defaultMiddleDivider)]
    }

    public func section(at index: Int) -> Section {

        let hasTopBookend = bookends == .top || bookends == .both

        if hasTopBookend && index == 0 {
            return bookendTopDivider
        }
        
        if (bookends == .bottom || bookends == .both) && index == saltedContentCount() - 1 {
            return bookendBottomDivider
        }

        let isContentIndex = hasTopBookend ? index % 2 != 0 : index % 2 == 0
        
        if isContentIndex {
            var total = 0
            for section in sections {
                let count = section.itemCount
                if count + total > unsaltedIndex(from: index) { return section }
                total += count
            }
        }

        return middleDivider ?? defaultMiddleDivider
    }

    public var itemCount: Int {
        return self.saltedContentCount()
    }

    public var reuseIdentifiers: [String]  {

        let middle = middleDivider?.reuseIdentifiers ?? defaultMiddleDivider.reuseIdentifiers
        var ids = bookendTopDivider.reuseIdentifiers + bookendBottomDivider.reuseIdentifiers + middle
        for section in sections {
            if let nestedSection = section as? NestedSection {
                ids.append(contentsOf: nestedSection.reuseIdentifiers)
            } else if let bedrockSection = section as? BedrockSection {
                ids.append(contentsOf: bedrockSection.reuseIdentifiers)
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
