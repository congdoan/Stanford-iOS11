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
                cardView.isFaceUp = true
                let card = cards.removeLast()
                cardView.rank = card.rank.order
                cardView.suit = card.suit.rawValue
                
                cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            }
        }
    }
    
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let cardView = sender.view as! PlayingCardView
            cardView.isFaceUp = !cardView.isFaceUp
        }
    }
    
}
