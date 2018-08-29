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

    @IBOutlet weak var cardView: PlayingCardView! {
        didSet {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onCardViewTap))
            cardView.addGestureRecognizer(tapRecognizer)
        }
    }
    
    @objc func onCardViewTap() {
        if deck.cards.isEmpty {
            deck = PlayingCardDeck()
        }
        let card = deck.draw()!
        cardView.rank = card.rank.order
        cardView.suit = card.suit.rawValue
    }
    
}
