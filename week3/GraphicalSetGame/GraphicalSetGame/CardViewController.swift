//
//  CardViewController.swift
//  GraphicalSetGame
//
//  Created by Cong Doan on 8/31/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    private var deck = Deck(shuffle: false)

    @IBOutlet weak var cardView: CardView! {
        didSet {
            let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeGesture(recognizedBy:)))
            swipeRecognizer.direction = [.left, .right]
            cardView.addGestureRecognizer(swipeRecognizer)
        }
    }
    
    @objc func onSwipeGesture(recognizedBy recognizer: UISwipeGestureRecognizer) {
        print(recognizer.state)
        let newCard = deck.deal(numberOfCards: 1)[0]
        populateCardView(with: newCard)
    }
    
    private func populateCardView(with card: Card) {
        cardView.number = card.number.rawValue
        
        cardView.color = card.color.uiColor
        
        switch card.shading {
        case .outline: cardView.fillingKind = .none
        case .solid: cardView.fillingKind = .solid
        case .striped: cardView.fillingKind = .striped
        }
        
        switch card.shape {
        case .circle: cardView.shape = .oval
        case .square: cardView.shape = .diamon
        case .triangle: cardView.shape = .squiggle
        }
    }
    
}
