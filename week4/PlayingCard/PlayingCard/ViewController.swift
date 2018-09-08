//
//  ViewController.swift
//  PlayingCard
//
//  Created by Cong Doan on 8/27/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var deck = PlayingCardDeck()
    
    private lazy var animator = UIDynamicAnimator(referenceView: view)
    
    private lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        //behavior.collisionMode = .everything // The default value is everything
        animator.addBehavior(behavior)
        return behavior
    }()
    
    private lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 1
        behavior.resistance = 0
        animator.addBehavior(behavior)
        return behavior
    }()

    @IBOutlet private var cardViews: [PlayingCardView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numCardPairs = (cardViews.count + 1) / 2
        var cards = [PlayingCard]()
        for _ in 1...numCardPairs {
            let card = deck.draw()!
            cards += [card, card]
        }
        cards.shuffle()
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.removeLast()
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            
            collisionBehavior.addItem(cardView)
            itemBehavior.addItem(cardView)
            let push  = UIPushBehavior(items: [cardView], mode: .instantaneous)
            push.angle = (2*CGFloat.pi).arc4random
            push.magnitude = CGFloat(1) + CGFloat(2).arc4random
            push.action = { [unowned push] in
                //self.animator.removeBehavior(push) // Cycle: self -> animator -> push -> action closure -> self
                push.dynamicAnimator?.removeBehavior(push)
            }
            animator.addBehavior(push)
        }
    }
    
    private var facedUpCardViews: [PlayingCardView] {
        return cardViews.filter { $0.isFaceUp && !$0.isHidden }
    }
    
    private var are2FacedUpCardsMatched: Bool {
        return facedUpCardViews[0].rank == facedUpCardViews[1].rank
            && facedUpCardViews[0].suit == facedUpCardViews[1].suit
    }
    
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        if sender.state != .ended { return }
        let cardView = sender.view as! PlayingCardView
        UIView.transition(
            with: cardView,
            duration: 0.6,
            options: [cardView.isFaceUp ? .transitionFlipFromLeft : .transitionFlipFromRight],
            animations: {
                cardView.isFaceUp = !cardView.isFaceUp
            },
            completion: { finished in
                if self.facedUpCardViews.count == 2 {
                    self.animate2FacedUpCardViews()
                }
            })
    }
    
    private func animate2FacedUpCardViews() {
        if are2FacedUpCardsMatched {
            animateMatchedPair()
        } else {
            animateMismatchedPair()
        }
    }
    
    private func animateMatchedPair() {
        // Scale back down, then fade out & finally be removed from the super view
        facedUpCardViews.forEach { view in
            // Scale up
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.6,
                delay: 0,
                animations: {
                    view.transform = CGAffineTransform.identity.scaledBy(x: 3, y: 3)
                },
                completion: { position in
                    // Simultaneously scale back down and fade out
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.75,
                        delay: 0.2,
                        animations: {
                            view.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                            view.alpha = 0
                        },
                        completion: { (position) in
                            // Hide
                            view.isHidden = true
                            view.alpha = 1
                            view.transform = .identity
                        })
                })
        }
    }
    
    private func animateMismatchedPair() {
        facedUpCardViews.forEach { facedUpCardView in
            UIView.transition(
                with: facedUpCardView,
                duration: 0.6,
                options: [.transitionFlipFromLeft],
                animations: {
                    facedUpCardView.isFaceUp = false
                })
        }
    }
    
}
