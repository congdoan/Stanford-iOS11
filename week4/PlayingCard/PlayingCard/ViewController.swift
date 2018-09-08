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
    
    private var cardViewsBeingFlippedUp = Set<PlayingCardView>()
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended && facedUpCardViews.count < 2 else { return }
        let cardView = sender.view as! PlayingCardView
        if !cardView.isFaceUp {
            cardBehavior.removeItem(cardView)
        }
        UIView.transition(
            with: cardView,
            duration: 0.5,
            options: [cardView.isFaceUp ? .transitionFlipFromLeft : .transitionFlipFromRight],
            animations: {
                cardView.isFaceUp = !cardView.isFaceUp
                
                if cardView.isFaceUp {
                    self.cardViewsBeingFlippedUp.insert(cardView)
                }
            },
            completion: { finished in
                if cardView.isFaceUp {
                    self.cardViewsBeingFlippedUp.remove(cardView)
                } else {
                    self.cardBehavior.addItem(cardView)
                }
                
                if self.cardViewsBeingFlippedUp.isEmpty {
                    let cardViewsToAnimate = self.facedUpCardViews
                    if cardViewsToAnimate.count == 2 {
                        self.animate2FacedUpCardViews(cardViewsToAnimate)
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

private func are2FacedUpCardsMatched(_ cardViewsToAnimate: [PlayingCardView]) -> Bool {
    return cardViewsToAnimate[0].rank == cardViewsToAnimate[1].rank
        && cardViewsToAnimate[0].suit == cardViewsToAnimate[1].suit
}

private func animateMatchedPair(_ cardViewsToAnimate: [PlayingCardView]) {
    UIViewPropertyAnimator.runningPropertyAnimator(
        withDuration: 0.5,
        delay: 0,
        // Scale Up
        animations: {
            cardViewsToAnimate.forEach {
                $0.transform = CGAffineTransform.identity.scaledBy(x: 3, y: 3)
            }
        },
        completion: { position in
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.6,
                delay: 0.2,
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
    let delay = 0.3
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
