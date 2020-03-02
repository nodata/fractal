//
//  CardViewController.swift
//  Mercari-Common
//
//  Created by Anthony Smith on 26/07/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation
import UIKit


public class CardViewController: UIViewController {

    public struct Option: OptionSet {
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let darkBackground = Option(rawValue: 1 << 0)
        public static let isFullscreen = Option(rawValue: 1 << 1)
        public static let showHandle = Option(rawValue: 1 << 2)
        public static let shouldScale = Option(rawValue: 1 << 3)
    }
    
    private static let scaleFactor: CGFloat = 0.05
    public private(set) var cardViews = [CardView]()
    private weak var topLevelViewController: UIViewController?
    private var snapshots = NSMapTable<UIView, UIView>(keyOptions: [.weakMemory], valueOptions: [.strongMemory])
    
    public init(topLevelViewController: UIViewController? = nil) {
        self.topLevelViewController = topLevelViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Actions
    
    @objc private func coverViewTapped() {
        
        guard !isIPad else { return }
        guard let cardView = cardViews.last else { return }
        guard cardView.viewController?.cardViewContentDelegate?.isBackgroundDismissable ?? true else { return }
        cardView.animateOut()
    }

    public func present(_ viewController: UIViewController, options: [Option] = []) {

        if cardViews.count == 0 {
            view.superview?.alpha = 1.0
        }
        
        let previousView = cardViews.count == 0 ? topLevelViewController?.view : cardViews.last
        let showHandle = options.contains(.showHandle)
        let shouldScale = options.contains(.shouldScale)

        if shouldScale, let prev = previousView, let snapshot = prev.snapshotView(afterScreenUpdates: true) {
            snapshots.setObject(snapshot, forKey: prev)
            view.addSubview(snapshot)
            snapshot.clipsToBounds = true
            snapshot.layer.cornerRadius = CardView.cornerRadius
            snapshot.pin(to: prev)
            prev.isHidden = true
        }
        
        let coverView = newCoverView(dark: options.contains(.darkBackground))
        let cardView = CardView(viewController: viewController, coverView: coverView, showHandle: showHandle, shouldScale: shouldScale)
        cardView.delegate = self
        
        let heightConstraint = viewController.cardViewContentDelegate?.heightConstraint(for: cardView.heightAnchor)
        let topPadding = viewController.cardViewContentDelegate?.topPadding
        let useCardTopPadding = !options.contains(.isFullscreen) || options.contains(.showHandle)
        
        let cardViewConstraints = cardView.cardViewConstraints(in: view,
                                                               with: heightConstraint,
                                                               useTopPadding: useCardTopPadding)
        cardView.yConstraint = cardViewConstraints[1]
        
        view.addSubview(coverView)
        view.addSubview(cardView)
        
        NSLayoutConstraint.activate(cardViewConstraints)
        NSLayoutConstraint.activate(coverView.coverViewConstraints(in:view))
        
        coverView.addGestureRecognizer(cardView.coverPanGestureRecognizer)
        
        if showHandle {
            view.addSubview(cardView.handleView)
            NSLayoutConstraint.activate(cardView.handleView.handleViewConstraints(with: cardView))
        }
        
        contain(viewController, constraintBlock:{ (childView) -> ([NSLayoutConstraint]) in
            cardView.addSubview(childView)
            childView.layer.cornerRadius = cardView.layer.cornerRadius
            return childView.viewControllerConstraints(in:cardView, with:topPadding)
        })

        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        cardViews.append(cardView)
        
        cardView.setBackgroundColor()
        cardView.yConstraint?.constant = cardView.bounds.size.height
        cardView.setNeedsUpdateConstraints()
        cardView.layoutIfNeeded()
        cardView.perform(#selector(cardView.animateIn), with: nil, afterDelay: 0.01)
    }

    public func dismissModalCard(with viewController: UIViewController, completion: (() -> Void)? = nil) {
        
        var found = false
        
        for cardView in cardViews {
            
            guard let vc = cardView.viewController else { continue }
            
            if let nvc = vc as? UINavigationController, let givenVCNVC = viewController.navigationController, givenVCNVC == nvc {
                found = true
            }
            else if cardView.viewController == viewController {
                found = true
            }
            
            guard found else { continue }
            
//            if let firstResponder = cardView.findFirstResponder() {
//                firstResponder.resignFirstResponder()
//            }
            
            if let prev = cardViews[safe: cardViews.count-2], prev.showHandle {
                UIView.animate(withDuration: 0.25,
                               delay: 0.0,
                               options: [.beginFromCurrentState,.curveEaseInOut],
                               animations:{ prev.handleView.alpha = 1.0 },
                               completion:nil)
            }
            
            cardView.animateOut(completion: completion)
            break
        }
    }
 
    // MARK: - Accessors

    private func newCoverView(dark:Bool) -> UIView {
        
        let view = UIView(frame:.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.0
        view.isUserInteractionEnabled = true
        
        if dark {
            view.backgroundColor = UIColor(white:0.0,alpha:0.6)
        }
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(coverViewTapped))
        view.addGestureRecognizer(tapGestureRecogniser)
        
        return view
    }
}

@available(iOS 11.0, *)
extension CardViewController: CardViewDelegate {
    
    public func cardViewWillAppear(_ cardView: CardView) -> () -> Void {
    
        return { [weak self] in
            
            guard cardView.shouldScale else { return }
            guard let `self` = self else { return }
            guard self.cardViews.count > 0 else { return }
            
            let scale = 1.0 - CardViewController.scaleFactor
            
            if self.cardViews.count == 1 {
                if let topVC = self.topLevelViewController, let snapshot = self.snapshots.object(forKey: topVC.view) {
                    snapshot.transform = CGAffineTransform(scaleX: scale, y: scale)
                    snapshot.layer.cornerRadius = CardView.cornerRadius
                }
            } else {
                let cardView = self.cardViews[self.cardViews.count - 2]
                if let snapshot = self.snapshots.object(forKey: cardView) {
                    snapshot.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
                
                if cardView.showHandle {
                    
                    UIView.animate(withDuration: 0.25,
                                   delay: 0.0,
                                   options: [.beginFromCurrentState,.curveEaseInOut],
                                   animations:{ cardView.handleView.alpha = 0.0 },
                                   completion:nil)
                }
            }
        }
    }
    
    public func cardViewWasPanned(_ cardView: CardView, percentage: CGFloat) {
        
        guard cardView.shouldScale else { return }
        guard percentage > 0.0 && percentage <= 1.0 else { return }
        let scale = 1.0 - CardViewController.scaleFactor + (CardViewController.scaleFactor * percentage)

        if cardViews.count == 1 {
            if let topVC = self.topLevelViewController, let snapshot = self.snapshots.object(forKey: topVC.view) {
                snapshot.transform = CGAffineTransform(scaleX: scale, y: scale)
                snapshot.layer.cornerRadius = CardView.cornerRadius - (CardView.cornerRadius * percentage)
            }
        }
        else if cardViews.count > 1 {
            let cardView = self.cardViews[self.cardViews.count - 2]
            if let snapshot = self.snapshots.object(forKey: cardView) {
                snapshot.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
    
    public func cardViewWillDismiss(_ cardView: CardView) -> () -> Void {
        
        return { [weak self] in
            
            guard cardView.shouldScale else { return }
            guard let `self` = self else { return }
            guard self.cardViews.count > 0 else { return }
            
            if self.cardViews.count == 1 {
                
                if let topVC = self.topLevelViewController, let snapshot = self.snapshots.object(forKey: topVC.view) {
                    snapshot.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    snapshot.layer.cornerRadius = 0.0
                }

            } else {
                let cardView = self.cardViews[self.cardViews.count - 2]
                if let snapshot = self.snapshots.object(forKey: cardView) {
                    snapshot.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
                
                if cardView.showHandle {
                    
                    UIView.animate(withDuration: 0.25,
                                   delay: 0.0,
                                   options: [.beginFromCurrentState,.curveEaseInOut],
                                   animations:{ cardView.handleView.alpha = 1.0 },
                                   completion:nil)
                }
            }
        }
    }
    
    public func cardViewDidDismiss(_ cardView: CardView) {
        
        guard let index = cardViews.firstIndex(of: cardView) else {
            //TODO: assert
            return
        }
        
        cardViews.remove(at: index)
        
        if let vc = cardView.viewController {
            dismissContained(vc)
        }
        
        cardView.coverView?.removeFromSuperview()
        cardView.removeFromSuperview()
        if cardView.showHandle {
            cardView.handleView.removeFromSuperview()
        }
        
        if let prev = cardViews.count == 0 ? topLevelViewController?.view : cardViews.last {
            snapshots.object(forKey: prev)?.removeFromSuperview()
            snapshots.removeObject(forKey: prev)
            prev.isHidden = false
        }

        if cardViews.count == 0 {
            view.superview?.alpha = 0.0
            snapshots.removeAllObjects()
        }        
    }
}

extension CardView {
    
    func cardViewConstraints(in superview: UIView, with heightConstraint: NSLayoutConstraint?, useTopPadding: Bool) -> [NSLayoutConstraint] {
        
        let x = centerXAnchor.constraint(equalTo:superview.centerXAnchor)
        let y = bottomAnchor.constraint(equalTo:superview.bottomAnchor, constant:bounds.size.height)
        let w = isIPad ? widthAnchor.constraint(equalToConstant: CardView.iPadWidth) : widthAnchor.constraint(equalTo:superview.widthAnchor)
        
        let heightConstant = useTopPadding ? CardView.bottomPadding - CardView.topPadding : CardView.bottomPadding

        guard let heightConstraint = heightConstraint else {
            let h = heightAnchor.constraint(equalTo:superview.heightAnchor, constant:heightConstant)
            return [x,y,w,h]
        }
        
        heightConstraint.constant += heightConstant
        
        return [x,y,w,heightConstraint]
    }
}

fileprivate extension UIView {
    
    func viewControllerConstraints(in superview: CardView, with topPadding: CGFloat?) -> [NSLayoutConstraint] {
        
        let x = centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        let y = topAnchor.constraint(equalTo: superview.topAnchor, constant: topPadding ?? 0.0)
        let y2 = bottomAnchor.constraint(equalTo: superview.bottomAnchor,constant: -CardView.bottomPadding)
        let w = widthAnchor.constraint(equalTo: superview.widthAnchor)
        
        return [x,y,y2,w]
    }
    
    func coverViewConstraints(in superview: UIView) -> [NSLayoutConstraint] {
        
        let x = centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        let y = centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        let w = widthAnchor.constraint(equalTo: superview.widthAnchor)
        let h = heightAnchor.constraint(equalTo: superview.heightAnchor)
        
        return [x,y,w,h]
    }

    func handleViewConstraints(with sibling: UIView) -> [NSLayoutConstraint] {
        
        let x = centerXAnchor.constraint(equalTo: sibling.centerXAnchor)
        let y = bottomAnchor.constraint(equalTo: sibling.topAnchor, constant: -10.0)
        
        return [x,y]
    }
}

extension UIViewController {
    
    var cardViewContentDelegate: CardViewContentDelegate? {
        
        if let delegate = self as? CardViewContentDelegate {
            return delegate
        } else if let nvc = self as? UINavigationController,
            let delegate = nvc.viewControllers.last as? CardViewContentDelegate {
            return delegate
        } else {
            for vc in children { if let delegate = vc as? CardViewContentDelegate { return delegate } }
        }
        
        return nil
    }
}
