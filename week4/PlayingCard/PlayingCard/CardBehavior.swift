//
//  CardBehavior.swift
//  PlayingCard
//
//  Created by Cong Doan on 9/8/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {

    private lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    private lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 1
        behavior.resistance = 0
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem) {
        let push  = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = (2*CGFloat.pi).arc4random
        push.magnitude = CGFloat(1) + CGFloat(2).arc4random
        push.action = { [unowned push, weak self] in
            // NOTE: using strong self would cause retain cycle "self -> push -> action closure -> self"
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    override init() {
        super.init()
        
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        
        animator.addBehavior(self)
    }
    
}
