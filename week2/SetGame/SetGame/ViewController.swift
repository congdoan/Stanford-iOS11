//
//  ViewController.swift
//  SetGame
//
//  Created by Cong Doan on 8/16/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let numberOfCardsToStart = 12

    @IBOutlet var cardButtons: [UIButton]! {
        didSet {
            cardButtons.forEach { (button) in
                button.layer.borderWidth = 0.5
                button.layer.borderColor = UIColor.black.withAlphaComponent(0.35).cgColor
                button.layer.cornerRadius = 8
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initiallyDealtCards = Deck(shuffle: true).deal(numberOfCards: numberOfCardsToStart)
        for idx in 0..<initiallyDealtCards.count {
            let card = initiallyDealtCards[idx]
            let button = cardButtons[idx]
            ViewController.display(button, card)
        }
        
        for idx in numberOfCardsToStart..<cardButtons.count {
            cardButtons[idx].isHidden = true
        }
    }
    
    private static func display(_ button: UIButton, _ card: Card) {
        let symbol = card.shape.unicodeString
        let color = card.color.uiColor
        
        let attr: [NSAttributedStringKey : Any]
        switch card.shading {
        case .outline:
            attr = [.strokeWidth: 2, .strokeColor: color]
        case .solid: //filled
            attr = [.strokeWidth: -1, .foregroundColor: color]
        case .striped:
            attr = [.foregroundColor: color.withAlphaComponent(0.20)]
        }
        
        let attrSymbol = NSAttributedString(string: symbol, attributes: attr)
        let attrTitle = NSMutableAttributedString(attributedString: attrSymbol)
        let number = card.number.rawValue
        if number >= 2 {
            for _ in 2...number {
                attrTitle.append(attrSymbol)
            }
        }
        
        button.setAttributedTitle(attrTitle, for: .normal)
    }

}

