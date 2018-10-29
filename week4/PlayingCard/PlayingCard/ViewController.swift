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
    private lazy var cardBehavior = CardBehavior(in: animator)

    @IBOutlet private var cardViews: [PlayingCardView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardBehavior.setCollisionDelegate(self)
        
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
            
            cardBehavior.addItem(cardView)
        }
    }
    
    private var facedUpCardViews: [PlayingCardView] {
        return cardViews.filter { $0.isFaceUp && !$0.isHidden && $0.transform == .identity && $0.alpha == 1 }
    }
    
    private var lastChosenCardView: PlayingCardView?
    
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended && facedUpCardViews.count < 2 else { return }
        let chosenCardView = sender.view as! PlayingCardView
        lastChosenCardView = chosenCardView
        if !chosenCardView.isFaceUp {
            cardBehavior.removeItem(chosenCardView)
        }
        UIView.transition(
            with: chosenCardView,
            duration: 0.6,
            options: [chosenCardView.isFaceUp ? .transitionFlipFromLeft : .transitionFlipFromRight],
            animations: {
                chosenCardView.isFaceUp = !chosenCardView.isFaceUp
            },
            completion: { finished in
                let cardViewsToAnimate = self.facedUpCardViews
                if cardViewsToAnimate.count == 2 {
                    if chosenCardView == self.lastChosenCardView {
                        self.animate2FacedUpCardViews(cardViewsToAnimate)
                    }
                } else {
                    if !chosenCardView.isFaceUp {
                        self.cardBehavior.addItem(chosenCardView)
                    }
                }
            })
    }
    
    private func animate2FacedUpCardViews(_ cardViewsToAnimate: [PlayingCardView]) {
        if are2FacedUpCardsMatched(cardViewsToAnimate) {
            animateMatchedPair(cardViewsToAnimate)
        } else {
            animateMismatchedPair(cardViewsToAnimate, cardBehavior)
        }
    }
    
}

extension ViewController: UICollisionBehaviorDelegate {
    private func updateItemCenterIfNeeded(_ referenceBounds: CGRect, _ item: UIDynamicItem, _ animator: UIDynamicAnimator) {
        if !referenceBounds.contains((item as! UIView).frame) {
            //print("Escaped but Capured back:", item)
            //cardBehavior.removeItem(item)
            item.center = referenceBounds.center
            animator.updateItem(usingCurrentState: item)
        }
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item1: UIDynamicItem, with item2: UIDynamicItem) {
        if let animator = behavior.dynamicAnimator, let referenceBounds = animator.referenceView?.bounds {
            updateItemCenterIfNeeded(referenceBounds, item1, animator)
            updateItemCenterIfNeeded(referenceBounds, item2, animator)
        }
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior,
                           beganContactFor item: UIDynamicItem,
                           withBoundaryIdentifier identifier: NSCopying?,
                           at p: CGPoint) {
        print("withBoundaryIdentifier:", identifier)
    }
    func collisionBehavior(_ behavior: UICollisionBehavior,
                           endedContactFor item: UIDynamicItem,
                           withBoundaryIdentifier identifier: NSCopying?) {
        print("withBoundaryIdentifier:", identifier)
    }
}

private func are2FacedUpCardsMatched(_ cardViewsToAnimate: [PlayingCardView]) -> Bool {
    return cardViewsToAnimate[0].rank == cardViewsToAnimate[1].rank
        && cardViewsToAnimate[0].suit == cardViewsToAnimate[1].suit
}

private func animateMatchedPair(_ cardViewsToAnimate: [PlayingCardView]) {
    UIViewPropertyAnimator.runningPropertyAnimator(
        withDuration: 0.6,
        delay: 0,
        // Scale Up
        animations: {
            cardViewsToAnimate.forEach {
                $0.transform = CGAffineTransform.identity.scaledBy(x: 3, y: 3)
            }
        },
        completion: { position in
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.7,
                delay: 0,
                // Scale back Down & Fade Out
                animations: {
                    cardViewsToAnimate.forEach {
                        $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                        $0.alpha = 0
                    }
                },
                completion: { (position) in
                    cardViewsToAnimate.forEach {
                        $0.isHidden = true
                        $0.alpha = 1
                        $0.transform = .identity
                    }
                })
    })
}

private func animateMismatchedPair(_ cardViewsToAnimate: [PlayingCardView], _ cardBehavior: CardBehavior) {
    let delay = 0.1
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        cardViewsToAnimate.forEach { facedUpCardView in
            UIView.transition(
                with: facedUpCardView,
                duration: 0.6,
                options: [.transitionFlipFromLeft],
                animations: {
                    facedUpCardView.isFaceUp = false
                },
                completion: { position in
                    cardBehavior.addItem(facedUpCardView)
                })
        }
    }
}
