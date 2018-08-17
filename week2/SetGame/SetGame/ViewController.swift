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
    private let deck = Deck()
    private lazy var cards = deck.deal(numberOfCards: numberOfCardsToStart)

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
            ViewController.setAttributedTitle(of: cardButtons[idx], basedOn: cards[idx])
        }
        
        for idx in numberOfCardsToStart..<cardButtons.count {
            cardButtons[idx].isHidden = true
        }
    }
    
    private static func setAttributedTitle(of button: UIButton, basedOn card: Card) {
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
    
    private var selectedCardIndices = [Int]()
    private var areSelectedCardsASet = false
    
    @IBAction func onCardButtonTap(_ sender: UIButton) {
        let btnIdx = sender.tag

        if selectedCardIndices.count == Deck.SET_SIZE {
            onTapWhen3CardsSelected(btnIdx)
            return
        }

        let button = cardButtons[btnIdx]
        if ViewController.toggleSelectionStatus(button) {
            selectedCardIndices.append(btnIdx)
            if selectedCardIndices.count == Deck.SET_SIZE {
                let selectedCards = selectedCardIndices.map{cards[$0]}
                areSelectedCardsASet = Deck.isSet(selectedCards)
                print("Selected Cards form a Set?:", areSelectedCardsASet)
            }
        } else {
            selectedCardIndices.remove(at: selectedCardIndices.index(of: btnIdx)!)
        }
    }
    
    private func onTapWhen3CardsSelected(_ tappedButtonIndex: Int) {
        if areSelectedCardsASet {
            if deck.isEmpty {
                for selectedIdx in selectedCardIndices {
                    cardButtons[selectedIdx].isHidden = true
                }
            } else {
                replaceWith(deck.deal())
            }
            selectedCardIndices = selectedCardIndices.contains(tappedButtonIndex) ? [] : [tappedButtonIndex]
            for selectedIdx in selectedCardIndices {
                ViewController.select(cardButtons[selectedIdx])
            }
        } else {
            for selectedIdx in selectedCardIndices {
                ViewController.deselect(cardButtons[selectedIdx])
            }
            ViewController.select(cardButtons[tappedButtonIndex])
            selectedCardIndices = [tappedButtonIndex]
        }
    }
    
    private func replaceWith(_ newlyDealtCards: [Card]) {
        for arrayIndex in newlyDealtCards.indices {
            let selectedCardIndex = selectedCardIndices[arrayIndex]
            let button = cardButtons[selectedCardIndex]
            let newCard = newlyDealtCards[arrayIndex]
            ViewController.deselect(button)
            ViewController.setAttributedTitle(of: button, basedOn: newCard)
        }
    }
    
    private static func toggleSelectionStatus(_ button: UIButton) -> Bool {
        let selected = button.layer.borderWidth == selectedCardBorderWidth
        if selected {
            deselect(button)
            return false
        } else {
            select(button)
            return true
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

