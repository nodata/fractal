//
//  CarouselViewController.swift
//  DesignSystem
//
//  Created by anthony on 26/11/2018.
//  Copyright © 2018 mercari. All rights reserved.
//
import Foundation

public class CarouselViewController: SectionCollectionViewController, BrandUpdateable {

    public var pagingType: PagingType = .false { didSet { setForNewPaging() }}

    public enum PagingType {
        case `false`,              // No CollectionView paging
        `true`,                    // Normal CollectionView paging behaviour
        calculated,                // Traverses all cells and holds onto their x values until reload
        calculatedFixed,           // Same as calculated but assumes items after index 0 are the same width
        calculatedDoubleJump       // Same as calculated but skips odd numbered master indexes
    }
    
    private struct CellXValues {
        let minX: CGFloat
        let maxX: CGFloat
    }
    
    private var cellXValues = [CellXValues]()
    
    public init(layout: UICollectionViewLayout? = nil) {
        super.init(useRefreshControl: false, layout: layout, direction: .horizontal)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        dataSource.willEndDrag = { [weak self] (scrollView, velocity, initialOffset, targetOffset) in
            return self?.interpretDragging(scrollView, velocity, initialOffset, targetOffset)
        }
    }
    
    private func setForNewPaging() {
        switch pagingType {
        case .true:
            collectionView.isPagingEnabled = true
            collectionView.decelerationRate = .normal
        case .false:
            collectionView.isPagingEnabled = false
            collectionView.decelerationRate = .normal
        default:
            collectionView.isPagingEnabled = false
            collectionView.decelerationRate = .fast
        }
    }
    
    public func brandWasUpdated() {
        reload()
    }

    public override func reloadDidFinish() {
        super.reloadDidFinish()
        
        cellXValues.removeAll()
        
        if pagingType == .calculatedFixed {
            for section in dataSource.sections {
                for i in 0..<section.itemCount {
                    guard let bedrock = dataSource.bedrock(in: section, index: i)?.0 else { continue }
                    let width = bedrock.size(in: view, at: i).width ?? collectionView.bounds.size.width
                    let xValues = CellXValues(minX: 0.0, maxX: width)
                    cellXValues.append(xValues)
                    if cellXValues.count >= 2 { break }
                }
            }
            
        } else {
            var previousX: CGFloat = 0.0
            for section in dataSource.sections {
                for i in 0..<section.itemCount {

                    guard let bedrock = dataSource.bedrock(in: section, index: i)?.0 else { continue }
                    let width = bedrock.size(in: view, at: i).width ?? collectionView.bounds.size.width
                    let xValues = CellXValues(minX: previousX, maxX: previousX + width)
                    cellXValues.append(xValues)
                    previousX += width
                }
            }
        }
    }
    
    private func interpretDragging(_ scrollView: UIScrollView, _ velocity: CGPoint, _ initialOffset: CGPoint, _ targetOffset: CGPoint) -> CGPoint {
        
        //TODO: also vertical scrolling
                
        guard pagingType != .false && pagingType != .true else { return targetOffset }

        guard abs(scrollView.contentOffset.x - initialOffset.x) > 30.0 else { return initialOffset }
                
        let target = targetForNext(in: scrollView, from: initialOffset.x, up: velocity.x > 0.0)
        return CGPoint(x: target, y: targetOffset.y)
    }
    
    private func targetForNext(in scrollView: UIScrollView, from inititalX: CGFloat, up: Bool) -> CGFloat {
        
        let maxX = scrollView.contentSize.width - scrollView.bounds.size.width
        let centerX = inititalX + scrollView.bounds.size.width/2
        let doubleJump = pagingType == .calculatedDoubleJump

        if up {
            
            guard cellXValues.count > 1 else { return inititalX }

            if inititalX == 0.0 && target(for: cellXValues[1], in: scrollView) > 0.0 {
                return target(for: cellXValues[1], in: scrollView)
            }
            
            guard pagingType != .calculatedFixed else { return inititalX + cellXValues[1].maxX }
            
            for i in 0..<cellXValues.count {
                let values = cellXValues[i]
                guard centerX >= values.minX && centerX < values.maxX else { continue }
                
                if doubleJump && (i + 1) % 2 == 0 {
                    guard cellXValues.count > i + 2 else { return inititalX }
                    return target(for: cellXValues[i+2], in: scrollView)
                } else {
                    guard cellXValues.count > i + 1 else { return maxX }
                    return target(for: cellXValues[i+1], in: scrollView)
                }
            }

        } else {
                        
            guard cellXValues.count > 1 else { return maxX }

            guard pagingType != .calculatedFixed else { return inititalX - cellXValues[1].maxX }

            if inititalX == maxX && target(for: cellXValues[cellXValues.count - 2], in: scrollView) < maxX {
                return target(for: cellXValues[cellXValues.count - 2], in: scrollView)
            }
            
            for i in 0..<cellXValues.count {
                let values = cellXValues[i]
                guard centerX <= values.maxX else { continue }

                if doubleJump && (i - 1) % 2 == 0 {
                     guard 0 < i - 2 else { return inititalX }
                     return target(for: cellXValues[i-2], in: scrollView)
                 } else {
                    guard 0 < i - 1 else { return 0.0 }
                    return target(for: cellXValues[i-1], in: scrollView)
                }
            }
        }
        
        print("Couldn't resolve")
        return inititalX
    }
    
    private func target(for cellValues: CellXValues, in scrollView: UIScrollView) -> CGFloat {
        let cellWidth = cellValues.maxX - cellValues.minX
        let delta = scrollView.bounds.size.width - cellWidth
        let target = cellValues.minX - delta/2
        return target
    }
}
