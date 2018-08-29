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
            let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipeRecognizer.direction = [.left, .right]
            cardView.addGestureRecognizer(swipeRecognizer)
            
            let pinchRecognizer = UIPinchGestureRecognizer(
                                    target: cardView,
                                    action: #selector(PlayingCardView.adjustFaceCardScale(byHandlingPinchRecognizedBy:)))
            cardView.addGestureRecognizer(pinchRecognizer)
        }
    }
    
    @objc func nextCard() {
        if let card = deck.draw() {
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
        }
    }
    
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            cardView.isFaceUp = !cardView.isFaceUp
        }
    }
    
}
