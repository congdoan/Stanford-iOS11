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

    @IBOutlet private var cardViews: [PlayingCardView]! {
        didSet {
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
            }
        }
    }
    
    private var facedUpCardViews: [PlayingCardView] {
        return cardViews.filter { $0.isFaceUp }
    }
    
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        if sender.state != .ended { return }
        let cardView = sender.view as! PlayingCardView
        UIView.transition(with: cardView,
                          duration: 0.6,
                          options: [cardView.isFaceUp ? .transitionFlipFromLeft : .transitionFlipFromRight],
                          animations: {
                                cardView.isFaceUp = !cardView.isFaceUp
                          },
                          completion: { finished in
                                if self.facedUpCardViews.count != 2 { return }
                                self.facedUpCardViews.forEach { facedUpCardView in
                                    UIView.transition(with: facedUpCardView,
                                                      duration: 0.6,
                                                      options: [.transitionFlipFromLeft],
                                                      animations: {
                                                            facedUpCardView.isFaceUp = false
                                                      })
                                }
                          })
    }
    
}
