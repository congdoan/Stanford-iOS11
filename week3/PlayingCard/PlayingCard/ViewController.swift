//
//  ViewController.swift
//  PlayingCard
//
//  Created by Cong Doan on 8/27/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cardView: PlayingCardView! {
        didSet {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onCardViewTap))
            cardView.addGestureRecognizer(tapRecognizer)
        }
    }
    
    @objc func onCardViewTap() {
        if cardView.isFaceUp {
            let randomBool = Bool.arc4random
            if randomBool {
                cardView.rank = (cardView.rank % 13) + 1
                cardView.suit = nextSuit(of: cardView.suit)
            } else {
                cardView.isFaceUp = false
            }
        } else {
            cardView.isFaceUp = true
        }
    }
    
    private func nextSuit(of suit: String) -> String {
        switch suit {
        case "♠": return "♣"
        case "♣": return "♦"
        case "♦": return "❤️"
        case "❤️": return "♠"
        default: return "♠"
        }
    }
    
}

extension Bool {
    static var arc4random: Bool {
        return arc4random_uniform(2) == 1 ? true : false
    }
}

