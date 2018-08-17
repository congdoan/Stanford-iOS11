//
//  ViewController.swift
//  SetGame
//
//  Created by Cong Doan on 8/16/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private static let selectedCardBorderWidth: CGFloat = 2
    
    private let numberOfCardsToStart = 12
    
    private lazy var cards = Deck(shuffle: true).deal(numberOfCards: numberOfCardsToStart)

    @IBOutlet var cardButtons: [UIButton]! {
        didSet {
            cardButtons.forEach { (button) in
                button.layer.cornerRadius = 8
                ViewController.deselect(button)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for idx in 0..<cards.count {
            ViewController.display(cardButtons[idx], cards[idx])
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
    
    @IBAction func onCardButtonTap(_ sender: UIButton) {
        let idx = sender.tag
        let button = cardButtons[idx]
        ViewController.toggleSelectionStatus(button)
    }
    
    private static func toggleSelectionStatus(_ button: UIButton) {
        let selected = button.layer.borderWidth == selectedCardBorderWidth
        if selected {
            deselect(button)
        } else {
            select(button)
        }
    }
    
    private static func deselect(_ button: UIButton) {
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.black.withAlphaComponent(0.35).cgColor
    }
    
    private static func select(_ button: UIButton) {
        button.layer.borderWidth = selectedCardBorderWidth
        button.layer.borderColor = UIColor.blue.cgColor
    }
    
}

