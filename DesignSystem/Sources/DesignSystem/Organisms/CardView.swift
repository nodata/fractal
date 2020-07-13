//
//  CardView.swift
//  Mercari
//
//  Created by Anthony Smith on 10/11/2017.
//  Copyright © 2017 Mercari, Inc. All rights reserved.
//

import Foundation
import UIKit

public protocol CardViewContentDelegate: CardViewDelegate {
    
    // Adding contentScrollView allows for drag to dismiss when your contentOffet.y is zero.
    var contentScrollView: UIScrollView? { get }
    
    // Dynamically disable and enable background tap to dismiss.. Always blocked on iPad.
    var isBackgroundDismissable: Bool { get }
    
    // Dynamically disable and enable dragging.
    var isDraggable: Bool { get }
    
    // Only fired on first VC:

    // Add a specific color for the card handle.
    var cardHandleColor: UIColor? { get }
    
    // Add padding between the top of the viewController and top of the card view.
    var topPadding: CGFloat { get }
    
    // Passing a constraint for the height layout dimension allows for any kind of dynamic height to be controlled by the viewcontroller... pass this around if you push to a different VC and want to change the constant
    func heightConstraint(for cardViewHeightAnchor: NSLayoutDimension, superview: UIView) -> NSLayoutConstraint?
}

public protocol CardViewDelegate: class {

    func cardViewWillAppear(_ cardView: CardView) -> () -> Void
    func cardViewDidAppear(_ cardView: CardView)
    func cardViewWasPanned(_ cardView: CardView, percentage: CGFloat)
    func cardViewWillDismiss(_ cardView: CardView) -> () -> Void
    func cardViewDidDismiss(_ cardView: CardView)
}

public extension CardViewContentDelegate {

    var contentScrollView: UIScrollView? { return nil }
    var isBackgroundDismissable: Bool { return true }
    var isDraggable: Bool { return true }

    var cardHandleColor: UIColor? { return nil }
    var topPadding: CGFloat { return 0.0 }
    func heightConstraint(for cardViewHeightAnchor: NSLayoutDimension, superview: UIView) -> NSLayoutConstraint? { return nil }
}

public extension CardViewDelegate {
    
    func cardViewWillAppear(_ cardView: CardView) -> () -> Void { return {} }
    func cardViewDidAppear(_ cardView: CardView) {}
    func cardViewWasPanned(_ cardView: CardView, percentage: CGFloat) {}
    func cardViewWillDismiss(_ cardView: CardView) -> () -> Void { return {} }
    func cardViewDidDismiss(_ cardView: CardView) {}
}

public class CardView: UIView {
    
    public static let cornerRadius: CGFloat = 8.0
    public static let iPadWidth: CGFloat = 500.0
    public static let bottomPadding: CGFloat = CardView.cornerRadius + 40.0
    public static let topPadding: CGFloat = UIApplication.shared.statusBarFrame.size.height + 15.0
    public static let handlePaddingHeight: CGFloat = 32.0
    
    private static let handleThreshold: CGFloat = 8.0
    private static let cardDragThreshold: CGFloat = 36.0

    private let animateInDuration: TimeInterval

    private var cardDragStart: CGFloat = 0.0
    private var cardDragCurrent: CGFloat = 0.0
    private var hasDraggedCard: Bool = false
    private var isTouchingScrollView: Bool = false
    private var animateAfterLayout: Bool = false
    
    let showHandle: Bool
    let shouldScale: Bool
    var yConstraint: NSLayoutConstraint?
    var canLayDormant = false //TODO: like new message card on Mail app
    
    weak var coverView: UIView?
    public private(set) weak var viewController: UIViewController?
    weak var delegate: CardViewDelegate?

    public init(viewController: UIViewController, coverView: UIView, showHandle: Bool, shouldScale: Bool) {
        
        self.coverView = coverView
        self.viewController = viewController
        self.showHandle = showHandle
        self.shouldScale = shouldScale
        animateInDuration = 0.5

        super.init(frame:.zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false
        layer.cornerRadius = CardView.cornerRadius
        isUserInteractionEnabled = true
        addGestureRecognizer(panGestureRecognizer)

        self.addLongShadow(.up)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handleTapped() {
        animateOut()
    }
    
    func setBackgroundColor() {
        if let bgColor = viewController?.view.backgroundColor, bgColor != .clear {
            backgroundColor = bgColor
        } else if let bgColor = contentScrollView?.backgroundColor, bgColor != .clear {
            backgroundColor = bgColor
        } else {
            backgroundColor = .background(.card)
        }
    }
    
    // MARK: - Animations & Gestures
    
    @objc func animateIn() {
        
        let vcBlock = (viewController as? CardViewDelegate)?.cardViewWillAppear(self)
        let block = delegate?.cardViewWillAppear(self)
        
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
        
        yConstraint?.constant = CardView.bottomPadding
        superview?.setNeedsUpdateConstraints()

        contentScrollView?.bounces = true
        contentScrollView?.showsVerticalScrollIndicator = true
        
        if showHandle {
            handleView.set(state: .down, animated: true)
        }
        
        UIView.animate(withDuration: animateInDuration,
                       delay: 0.0,
                       usingSpringWithDamping: 0.85,
                       initialSpringVelocity: 0.0,
                       options: [.beginFromCurrentState,.curveEaseOut],
                       animations:{

                        self.superview?.layoutIfNeeded()
                        vcBlock?()
                        block?()
        },
                       completion:{ (finished) in

                        (self.viewController as? CardViewDelegate)?.cardViewDidAppear(self)
                        self.delegate?.cardViewDidAppear(self)
        })

        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: [.beginFromCurrentState,.curveEaseInOut],
                       animations:{

                        self.coverView?.alpha = 1.0
        },
                       completion:nil)
    }
    
    func animateOut(completion: (() -> Void)? = nil) {
        
        let vcBlock = (viewController as? CardViewDelegate)?.cardViewWillDismiss(self)
        let block = delegate?.cardViewWillDismiss(self)
        
        yConstraint?.constant = bounds.size.height
        superview?.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: [.beginFromCurrentState,.curveEaseOut],
                       animations:{
                        
                        vcBlock?()
                        block?()
                        self.superview?.layoutIfNeeded()
                        self.coverView?.alpha = 0.0
        },
                       completion:{ (finished) in
                        
                        completion?()
                        if let vcDelgate = self.viewController as? CardViewDelegate {
                            vcDelgate.cardViewDidDismiss(self)
                        }
                        self.delegate?.cardViewDidDismiss(self)
        })
    }
    
    @objc private func panned(panGestureRecogniser:UIPanGestureRecognizer) {
        
        guard viewController?.cardViewContentDelegate?.isDraggable ?? true else { return }

        let offset = panGestureRecogniser.translation(in: nil)
        
        switch panGestureRecogniser.state {
        case .began:
            let point = panGestureRecogniser.location(in: contentScrollView)
            isTouchingScrollView = contentScrollView?.bounds.contains(point) ?? false
            hasDraggedCard = false
            break
        case .changed:
            
            let contentScrollViewOffsetY = contentScrollView?.contentOffset.y ?? 0.0

            guard (hasDraggedCard && cardDragCurrent > 0.0) || (offset.y > 0.0 && (!isTouchingScrollView || contentScrollViewOffsetY <= 0.0)) else {
                
                handleView.set(state: .down, animated: true)
                contentScrollView?.bounces = true
                contentScrollView?.showsVerticalScrollIndicator = true
                return
            }
            
            if !hasDraggedCard {
                hasDraggedCard = true
                cardDragStart = offset.y
            }
            
            if isTouchingScrollView {
                contentScrollView?.bounces = false
                contentScrollView?.showsVerticalScrollIndicator = false
            }
            
            let offsetY = offset.y - cardDragStart
            cardDragCurrent = offsetY < 0.0 ? 0.0:offsetY
            yConstraint?.constant = CardView.bottomPadding + cardDragCurrent
            
            let percentage = cardDragCurrent / bounds.size.height
            
            coverView?.alpha = 1.0 - (1.0 * percentage)
            
            if let vcDelgate = viewController as? CardViewDelegate {
                vcDelgate.cardViewWasPanned(self,percentage:percentage)
            }
            
            delegate?.cardViewWasPanned(self,percentage:percentage)

            if showHandle {

                if cardDragCurrent > CardView.handleThreshold {
                    handleView.set(state: .neutral, animated: true)
                } else {
                    handleView.set(state: .down, animated: true)
                }
            }

        case .ended, .cancelled:
            
            guard hasDraggedCard else { return }
            
            if cardDragCurrent < CardView.cardDragThreshold || panGestureRecogniser.velocity(in: nil).y < 0.0 {
                animateIn()
            } else {
                animateOut()
            }
            
        default:
            break
        }
    }
    
    // MARK: - Accessors
    
    private var contentScrollView: UIScrollView? {
        return viewController?.cardViewContentDelegate?.contentScrollView
    }
    
    // MARK: - Properties
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned))
        panGestureRecognizer.delegate = self
        return panGestureRecognizer
    }()

    lazy var coverPanGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned))
        panGestureRecognizer.delegate = self
        return panGestureRecognizer
    }()
    
    lazy var handleView: DrawerHandleView = {
        let view = DrawerHandleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let color = self.viewController?.cardViewContentDelegate?.cardHandleColor
        view.strokeColor = color ?? .white //TODO: dark mode / dark cover
        view.addShortShadow()
        return view
    }()
}

extension CardView: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
     
        guard gestureRecognizer == panGestureRecognizer, otherGestureRecognizer == contentScrollView?.panGestureRecognizer else {
            return false
        }
        
        if let pan = otherGestureRecognizer as? UIPanGestureRecognizer {
            let v = pan.velocity(in: nil)
            guard abs(v.x) < abs(v.y) + 100.0 else { return false }
        }
        
        return true
    }
}

public extension UIColor.Key {
    static let card = UIColor.Key("card")
}
