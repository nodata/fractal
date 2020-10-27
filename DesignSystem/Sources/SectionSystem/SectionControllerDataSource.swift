//
//  SectionControllerDataSource.swift
//  SectionSystem
//
//  Created by anthony on 21/12/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation
import UIKit

open class SectionControllerDataSource: NSObject {

    public private(set) var newSections: Bool = false
    private weak var viewController: UIViewController?
    private var initialContentOffset: CGPoint = .zero
    private var currentIndexPath = IndexPath(item: 0, section: 0)

    public var sections: [Section] = [] {
        willSet { decoupleAllVisible() }
        didSet { newSections = true }
    }
    public var offset: CGFloat = 0.0 // TODO: Look at changing sections, potentially find current cell and keep hold of it, creating non moving section reloading if needed
    public var didScroll: ((UIScrollView) -> Void)?
    public var willEndDrag: ((_ scrollView: UIScrollView, _ velocity: CGPoint, _ initialOffset: CGPoint, _ targetContentOffset: CGPoint) -> CGPoint?)?
    public var didEndDecelerating: ((UIScrollView) -> Void)?
    public var didEndScrollingAnimation: ((UIScrollView) -> Void)?
    public var sectionTitles: [String]?
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
    }

    func bedrock(in section: Section, index: Int) -> (BedrockSection, Int)? {
        if let nestedSection = section as? NestedSection {
            //guard index < nestedSection.itemCount else { return nil }
            guard let givenSectionIndex = nestedSection.givenSectionIndex(from: index) else { return nil }
            return bedrock(in: nestedSection.section(at: index), index: givenSectionIndex)
        } else if let bedrock = section as? BedrockSection {
            return (bedrock, index)
        }

        Assert("Section in array \(String(describing: section)) not Nested or Bedrock type")
        return nil
    }

    func bedrock(for indexPath: IndexPath) -> (section: BedrockSection, index: Int)? {
        guard indexPath.section < sections.count else { return nil }
        return bedrock(in: sections[indexPath.section], index: indexPath.item)
    }

    func notifySectionsOfReload(in indexes: [Int]) {

        func notifyNestOfReload(_ nestedSection: NestedSection) {
            for section in nestedSection.allSections {
                section.pullData()
                section.willReload()
                if let n = section as? NestedSection { notifyNestOfReload(n) }
            }
        }

        if indexes.count > 0 {
            for index in indexes {
                let section = sections[index]
                if let n = section as? NestedSection { notifyNestOfReload(n) }
                section.pullData()
                section.willReload()
            }
        } else {
            for section in sections {
                if let n = section as? NestedSection { notifyNestOfReload(n) }
                section.pullData()
                section.willReload()
            }
        }
    }
    
    public func registerCells(in collectionView: UICollectionView, with registeredReuseIdentifiers: inout Set<String>) {

        if registeredReuseIdentifiers.isEmpty {
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: defaultReuseIdentifier)
            registeredReuseIdentifiers.insert(defaultReuseIdentifier)
        }

        for section in sections {
            if let nestedSection = section as? NestedSection {
                for id in nestedSection.reuseIdentifiers {
                    guard !registeredReuseIdentifiers.contains(id) else { continue }
                    registeredReuseIdentifiers.insert(id)
                    collectionView.register(SectionCollectionViewCell.self, forCellWithReuseIdentifier: id)
                }
            } else if let bedrockSection = section as? BedrockSection {
                for id in bedrockSection.reuseIdentifiers {
                    guard !registeredReuseIdentifiers.contains(id) else { continue }
                    registeredReuseIdentifiers.insert(id)
                    collectionView.register(SectionCollectionViewCell.self, forCellWithReuseIdentifier: id)
                }
            }
        }
        newSections = false
    }

    func registerCells(in tableView: UITableView, with registeredReuseIdentifiers: inout Set<String>) {

        if registeredReuseIdentifiers.isEmpty {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: defaultReuseIdentifier)
            registeredReuseIdentifiers.insert(defaultReuseIdentifier)
        }

        for section in sections {
            if let nestedSection = section as? NestedSection {
                for id in nestedSection.reuseIdentifiers {
                    guard !registeredReuseIdentifiers.contains(id) else { continue }
                    registeredReuseIdentifiers.insert(id)
                    tableView.register(SectionTableViewCell.self, forCellReuseIdentifier: id)
                }
            } else if let bedrockSection = section as? BedrockSection {
                for id in bedrockSection.reuseIdentifiers {
                    guard !registeredReuseIdentifiers.contains(id) else { continue }
                    registeredReuseIdentifiers.insert(id)
                    tableView.register(SectionTableViewCell.self, forCellReuseIdentifier: id)
                }
            } else {
                Assert("Section in array \(String(describing: section)) not Nested or Bedrock type")
            }
        }
        newSections = false
    }

    private func decoupleAllVisible() {

        func decouple(in section: Section) {
            if let section = section as? NestedSection {
                for s in section.allSections { decouple(in: s) }
            } else if let section = section as? ViewSection {
                section.decoupleVisibleViews()
            } else if let section = section as? ViewControllerSection {
                section.decoupleVisibleViewControllers()
            }
        }

        for section in sections { decouple(in: section) }
    }
    
    public func tearDownCellSubviews() {
        
        func tearDown(in section: Section) {
            
            guard !section.avoidTeardown else { return }
            
            if let section = section as? NestedSection {
                for s in section.allSections { tearDown(in: s) }
            } else if let section = section as? ViewSection {
                section.deleteVisibleViews()
            } else if let section = section as? ViewControllerSection {
                section.deleteVisibleViewControllers()
            }
        }

        for section in sections { tearDown(in: section) }
    }
}

extension SectionControllerDataSource: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        offset = scrollView.contentOffset.x
        didScroll?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        initialContentOffset = scrollView.contentOffset
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let newTarget = willEndDrag?(scrollView, velocity, initialContentOffset, targetContentOffset.pointee) {
            targetContentOffset.pointee = newTarget
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        didEndScrollingAnimation?(scrollView)
    }
}

extension SectionControllerDataSource: UITableViewDataSource, UITableViewDelegate {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < sections.count else { return 0 }
        return sections[section].itemCount
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let bedrock = bedrock(for: indexPath) else { return 10.0 }
        return bedrock.section.height(in: tableView, at: bedrock.index) ?? UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let bedrock = bedrock(for: indexPath) else {
            return defaultCell(at: indexPath, in: tableView)
        }

        let section = bedrock.section
        let index = bedrock.index

        guard let cell = tableView.dequeueReusableCell(withIdentifier: section.reuseIdentifier, for: indexPath) as? SectionTableViewCell else {
            print("TableView unable to dequeue cell for Section: \(String(describing: section)) ReuseId:\(section.reuseIdentifier)")
            return defaultCell(at: indexPath, in: tableView)
        }

        if let viewSection = section as? ViewSection {

            cell.section = viewSection
            
            guard let view = cell.sectionView else {
                let sectionView = viewSection.createView()
                cell.contentView.addSubview(sectionView)
                sectionView.pin(to: cell.contentView)
                cell.sectionView = sectionView
                viewSection.set(visibleView: sectionView, at: index)
                viewSection.configure(sectionView, at: index)
                cell.contentView.setNeedsLayout()
                cell.contentView.layoutIfNeeded()
                return cell
            }

            viewSection.set(visibleView: view, at: index)
            viewSection.configure(view, at: index)

            return cell

        } else if let viewControllerSection = section as? ViewControllerSection {

            cell.section = viewControllerSection

            guard let vc = cell.sectionViewController else {

                let newVC = viewControllerSection.createViewController()

                if let parentVC = viewController {
                    parentVC.contain(newVC) { (containerView) -> ([NSLayoutConstraint]) in
                        cell.contentView.addSubview(containerView)
                        return containerView.pin(to: cell.contentView)
                    }
                }

                cell.sectionViewController = newVC
                viewControllerSection.set(visibleViewController: newVC, at: index)
                viewControllerSection.configure(newVC, at: index)
                cell.contentView.setNeedsLayout()
                cell.contentView.layoutIfNeeded()
                return cell
            }

            viewControllerSection.set(visibleViewController: vc, at: index)
            viewControllerSection.configure(vc, at: index)

            return cell
        }

        return cell
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? { sectionTitles }

    private func defaultCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: defaultReuseIdentifier, for: indexPath)
        defaultCell.backgroundColor = .red //TODO: use for debug only... maybe assert
        return defaultCell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SectionTableViewCell, let view = cell.sectionView else { return }
        guard let bedrock = bedrock(for: indexPath) else { return }
        bedrock.section.didSelect(view, at: bedrock.index)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        guard let cell = cell as? SectionTableViewCell else { return }
        
        if let viewControllerSection = cell.section as? ViewControllerSection, let vc = cell.sectionViewController {
            viewControllerSection.decoupleVisibleViewController(vc)
        } else if let viewSection = cell.section as? ViewSection, let v = cell.sectionView {
            viewSection.decoupleVisibleView(v)
        }
        
        cell.section = nil
    }
}

extension SectionControllerDataSource: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < sections.count else { return 0 }
        return sections[section].itemCount
    }

    @objc public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let defaultSize = CGSize(width: collectionView.bounds.size.width, height: 44.0)
        guard let bedrock = bedrock(for: indexPath) else { return defaultSize }
        let section = bedrock.section
        let index = bedrock.index
        let v = collectionView.superview ?? collectionView
        let sectionSize = section.size(in: v, at: index)
        
        if let height = sectionSize.height, (collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == .horizontal {
            let maxHorizontal = collectionView.bounds.size.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)
            guard height <= maxHorizontal else {
                return CGSize(width: sectionSize.width ?? defaultSize.width, height: maxHorizontal)
            }
        } else if let width = sectionSize.width, (collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == .vertical {
            let maxVertical = collectionView.bounds.size.height - (collectionView.contentInset.right + collectionView.contentInset.left)
            guard width <= maxVertical else {
                return CGSize(width: maxVertical, height: sectionSize.height ?? defaultSize.height)
            }
        }
        
        return CGSize(width: sectionSize.width ?? defaultSize.width, height: sectionSize.height ?? defaultSize.height)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let bedrock = bedrock(for: indexPath) else {
            return defaultCell(at: indexPath, in: collectionView)
        }

        let section = bedrock.section
        let index = bedrock.index

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: section.reuseIdentifier, for: indexPath) as? SectionCollectionViewCell else {
            return defaultCell(at: indexPath, in: collectionView)
        }

        if let viewSection = section as? ViewSection {

            cell.section = viewSection
            cell.indexPath = indexPath

            guard let view = cell.sectionView else {

                let sectionView = viewSection.createView()
                cell.contentView.addSubview(sectionView)
                sectionView.pin(to: cell.contentView)
                cell.sectionView = sectionView
                viewSection.set(visibleView: sectionView, at: index)
                viewSection.configure(sectionView, at: index)
                cell.contentView.setNeedsLayout()
                cell.contentView.layoutIfNeeded()
                return cell
            }

            viewSection.set(visibleView: view, at: index)
            viewSection.configure(view, at: index)

            return cell

        } else if let viewControllerSection = section as? ViewControllerSection {

            cell.section = viewControllerSection
            cell.indexPath = indexPath

            guard let vc = cell.sectionViewController else {

                let newVC = viewControllerSection.createViewController()

                if let parentVC = viewController {
                    parentVC.contain(newVC) { (containerView) -> ([NSLayoutConstraint]) in
                        cell.contentView.addSubview(containerView)
                        return containerView.pin(to: cell.contentView)
                    }
                }
                
                cell.sectionViewController = newVC
                viewControllerSection.set(visibleViewController: newVC, at: index)
                viewControllerSection.configure(newVC, at: index)
                cell.contentView.setNeedsLayout()
                cell.contentView.layoutIfNeeded()
                return cell
            }

            viewControllerSection.set(visibleViewController: vc, at: index)
            viewControllerSection.configure(vc, at: index)

            return cell
        }

        return cell
    }

    private func defaultCell(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let defaultCell = collectionView.dequeueReusableCell(withReuseIdentifier: defaultReuseIdentifier, for: indexPath)
        defaultCell.backgroundColor = .red //TODO: use for debug only... maybe assert
        return defaultCell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SectionCollectionViewCell, let view = cell.sectionView else { return }
        guard let bedrock = bedrock(for: indexPath) else { return }
        bedrock.section.didSelect(view, at: bedrock.index)
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SectionCollectionViewCell else { return }
        
        if let viewControllerSection = cell.section as? ViewControllerSection, let vc = cell.sectionViewController {
            viewControllerSection.decoupleVisibleViewController(vc)
        } else if let viewSection = cell.section as? ViewSection, let v = cell.sectionView {
            viewSection.decoupleVisibleView(v)
        }
        
        cell.section = nil
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard sections.count > section else { return .zero }
        return sections[section].sectionInsets
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard sections.count > section else { return 0.0 }
        return sections[section].minimumLineSpacing
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard sections.count > section else { return 0.0 }
        return sections[section].minimumInteritemSpacing
    }
}

extension SectionControllerDataSource: UITableViewDragDelegate, UITableViewDropDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard let bedrock = bedrock(for: indexPath) else { return false }
        return bedrock.section.draggable // Will need to delegate more for specific rules in the future
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let bedrock = bedrock(for: indexPath) else { return false }
        return bedrock.section.draggable
    }
    
    public func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(for: indexPath)
    }
  
    public func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        var indexPath: IndexPath?
        tableView.performUsingPresentationValues {
            indexPath = tableView.indexPathForRow(at: session.location(in: tableView))
        }

        
        let cancel = UITableViewDropProposal(operation: .cancel, intent: .unspecified)
        guard let destination = indexPath else { return cancel }
        guard let bedrock = bedrock(for: destination) else { return cancel }
        guard bedrock.section.draggable else { return cancel }
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
                
        var indexPath: IndexPath?
        collectionView.performUsingPresentationValues {
            indexPath = collectionView.indexPathForItem(at: session.location(in: collectionView))
        }
        
        let cancel = UICollectionViewDropProposal(operation: .cancel, intent: .unspecified)
        guard let destination = indexPath else { return cancel }
        guard let bedrock = bedrock(for: destination) else { return cancel }
        guard bedrock.section.draggable else { return cancel }
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    public func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let original = coordinator.items[safe: 0]?.dragItem.localObject as? IndexPath else { return }
        guard let destination = coordinator.destinationIndexPath else { return }
        print("destination", destination.section, destination.row)
        guard let bedrock = bedrock(for: destination) else { return }
        guard bedrock.section.draggable else { return }
        bedrock.section.cellDragged(from: original, to: destination)
    }
    
    public func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let original = coordinator.items[safe: 0]?.dragItem.localObject as? IndexPath else { return }
        guard let destination = coordinator.destinationIndexPath else { return }
        guard let bedrock = bedrock(for: destination) else { return }
        guard bedrock.section.draggable else { return }
        bedrock.section.cellDragged(from: original, to: destination)
    }
    
    private func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        guard let bedrock = bedrock(for: indexPath) else { return [] }
        guard bedrock.section.draggable else { return [] }
        let provider = NSItemProvider(object: "\(indexPath.section)_\(indexPath.row)" as NSString)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = indexPath
        return [item]
    }
}


