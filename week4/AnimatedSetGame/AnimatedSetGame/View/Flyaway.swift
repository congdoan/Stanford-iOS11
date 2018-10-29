//
//  Flyaway.swift
//  AnimatedSetGame
//
//  Created by Cong Doan on 10/13/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class Flyaway: UIDynamicBehavior {
    
    private lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    //private lazy var itemBehavior = UIDynamicItemBehavior()
    private lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        //behavior.allowsRotation = true // Default value
        //behavior.resistance = 0 // Default value
        behavior.angularResistance = 0 // Default value = 0.1
        behavior.friction = 0 // Default value = 0.2
        return behavior
    }()
    
    private func pushItem(_ item: UIDynamicItem) {
        let pushBehavior = UIPushBehavior(items: [item], mode: .instantaneous)
        // Randomly push item toward the center of reference bounds
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let angle: CGFloat
            let center = referenceBounds.center
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y < center.y:
                angle = (CGFloat.pi/2).arc4random
            case let (x, y) where x > center.x && y < center.y:
                angle = CGFloat.pi - (CGFloat.pi/2).arc4random
            case let (x, y) where x > center.x && y > center.y:
                angle = CGFloat.pi + (CGFloat.pi/2).arc4random
            case let (x, y) where x < center.x && y > center.y:
                angle = (-CGFloat.pi/2).arc4random // <-> 2*CGFloat.pi - (CGFloat.pi/2).arc4random
            default:
                angle = (CGFloat.pi*2).arc4random
            }
            pushBehavior.angle = angle
        }
        pushBehavior.magnitude = CGFloat(28.0) + CGFloat(3.0).arc4random
        // Once it pushs the item remove itself without memory leak
        pushBehavior.action = { [unowned pushBehavior, weak self] in
            self?.removeChildBehavior(pushBehavior)
        }
        addChildBehavior(pushBehavior)
    }

    private let snapPoint: CGPoint
    
    private static func randomSign() -> Int {
        return arc4random_uniform(2) == 0 ? 1 : -1
    }
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        itemBehavior.addAngularVelocity(11, for: item)
        let xSign = Flyaway.randomSign(); let ySign = Flyaway.randomSign()
        let linearVelocity = CGPoint(x: xSign * 1000, y: ySign * 1000)
        itemBehavior.addLinearVelocity(linearVelocity, for: item)
        pushItem(item)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            self.removeItem(item)
        }
    }
    
    private lazy var itemBehaviorToSlowDownSnapBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.resistance = 116
        return behavior
    }()
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
        
        itemBehaviorToSlowDownSnapBehavior.addItem(item)
        let snapBehavior = UISnapBehavior(item: item, snapTo: self.snapPoint)
        addChildBehavior(snapBehavior)
        
        // Fate-out item view then remove itself from its super view (i.e. 'cardsContainerView')
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let itemView = item as! UIView
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5,
                delay: 0,
                options: [],
                animations: {
                    itemView.alpha = 0
                },
                completion: { finalPosition in
                    self.removeChildBehavior(snapBehavior)
                    self.itemBehaviorToSlowDownSnapBehavior.removeItem(item)
                    itemView.removeFromSuperview()
                })
        }
    }
    
    /*
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
        addChildBehavior(itemBehaviorToSlowDownSnapBehavior)
    }
    */
    init(snapPoint: CGPoint) {
        self.snapPoint = snapPoint
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
        addChildBehavior(itemBehaviorToSlowDownSnapBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator, snapPoint: CGPoint) {
        self.init(snapPoint: snapPoint)
        animator.addBehavior(self)
    }

}

extension CGFloat {
    var arc4random: CGFloat {
        return self * CGFloat(arc4random_uniform(UInt32.max)) / CGFloat(UInt32.max)
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}
