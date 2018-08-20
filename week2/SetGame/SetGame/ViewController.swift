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
    private let deck = Deck()
    private lazy var cards = deck.deal(numberOfCards: numberOfCardsToStart)

    @IBOutlet weak var verticalStackView: UIStackView!
    
    private var cardButtons: [UIButton]!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        verticalStackView.removeAllSubviews()
        cardButtons = populateVerticalStackView()
        
        for idx in 0..<cards.count {
            ViewController.setAttributedTitle(of: cardButtons[idx], basedOn: cards[idx])
        }
        
        for idx in cards.count..<cardButtons.count {
            cardButtons[idx].alpha = 0
        }
    }
    
    private func populateVerticalStackView() -> [UIButton] {
        let rows = traitCollection.verticalSizeClass == .regular ? Constant.rowsInRegularHeight
                                                                 : Constant.rowsInCompactHeight
        let cols = traitCollection.horizontalSizeClass == .regular ? Constant.colsInRegularWidth
                                                                   : Constant.colsInCompactWidth
        
        var cardButtons = [UIButton]()
        
        for row in 0..<rows {
            let horizontalStackView = UIStackView()
            horizontalStackView.axis = .horizontal
            horizontalStackView.spacing = Constant.CardButton.spacing
            horizontalStackView.distribution = .fillEqually
            for col in 0..<cols {
                let button = UIButton()
                button.tag = row * cols + col
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Constant.CardButton.titleFontSize)
                ViewController.deselect(button)
                button.layer.cornerRadius = Constant.CardButton.cornerRadius
                button.addTarget(self, action: #selector(onCardButtonTap(_:)), for: .touchUpInside)
                horizontalStackView.addArrangedSubview(button)
                cardButtons.append(button)
            }
            verticalStackView.addArrangedSubview(horizontalStackView)
        }
        
        return cardButtons
    }
    
    private static func setAttributedTitle(of button: UIButton, basedOn card: Card) {
        let symbol = card.shape.unicodeString
        let color = card.color.uiColor
        
        let attr: [NSAttributedStringKey : Any]
        switch card.shading {
        case .outline:
            attr = [.strokeWidth: Constant.CardShading.strokeWidthOfOutline, .strokeColor: color]
        case .solid: //filled
            attr = [.strokeWidth: Constant.CardShading.strokeWidthOfSolid, .foregroundColor: color]
        case .striped:
            attr = [.foregroundColor: color.withAlphaComponent(Constant.CardShading.alphaComponentOfStriped)]
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
    private var score = 0

    @objc func onCardButtonTap(_ sender: UIButton) {
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
                score += areSelectedCardsASet ? Constant.Score.match : Constant.Score.mismatch
                scoreLabel.text = "Score: \(score)"
                updateEnabledStatusOfDealButton()
            }
        } else {
            selectedCardIndices.remove(at: selectedCardIndices.index(of: btnIdx)!)
            score += Constant.Score.deselect
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    @IBOutlet weak var dealButton: UIButton!
    @IBAction func onDealButtonTap(_ sender: Any) {
        if selectedCardIndices.count == Deck.SET_SIZE && areSelectedCardsASet {
            replaceWith(deck.deal())
            selectedCardIndices = []
        } else {
            addWith(deck.deal())
        }
        updateEnabledStatusOfDealButton()
    }
    
    private func updateEnabledStatusOfDealButton() {
        dealButton.isEnabled = !deck.isEmpty
                                && (selectedCardIndices.count == Deck.SET_SIZE && areSelectedCardsASet
                                    || cards.count < cardButtons.count)
    }
    
    private func onTapWhen3CardsSelected(_ tappedButtonIndex: Int) {
        if areSelectedCardsASet {
            if deck.isEmpty {
                hideSelectedCards()
            } else {
                replaceWith(deck.deal(), completion: updateEnabledStatusOfDealButton)
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
    
    private func hideSelectedCards() {
        for selectedIdx in selectedCardIndices {
            /* Since use Stack View we set 'alpha = 0' instead of 'isHidden = true' */
            //cardButtons[selectedIdx].isHidden = true
            cardButtons[selectedIdx].alpha = 0
        }
    }
    
    private func replaceWith(_ newlyDealtCards: [Card], completion: (() -> Void)? = nil) {
        for arrayIndex in newlyDealtCards.indices {
            let selectedCardIndex = selectedCardIndices[arrayIndex]
            let button = cardButtons[selectedCardIndex]
            let newCard = newlyDealtCards[arrayIndex]
            cards[selectedCardIndex] = newCard
            ViewController.deselect(button)
            ViewController.setAttributedTitle(of: button, basedOn: newCard)
        }
        completion?()
    }
    
    private func addWith(_ newlyDealtCards: [Card]) {
        let start = cards.count
        cards.append(contentsOf: newlyDealtCards)
        for index in newlyDealtCards.indices {
            ViewController.setAttributedTitle(of: cardButtons[start + index], basedOn: newlyDealtCards[index])
            cardButtons[start + index].alpha = 1
        }
    }
    
    private static func toggleSelectionStatus(_ button: UIButton) -> Bool {
        let selected = button.layer.borderWidth == Constant.CardButton.borderWidthOfSelected
        if selected {
            deselect(button)
            return false
        } else {
            select(button)
            return true
        }
    }
    
    private static func deselect(_ button: UIButton) {
        button.layer.borderWidth = Constant.CardButton.borderWidthOfUnselected
        button.layer.borderColor = Constant.CardButton.borderColorOfUnselected
    }
    
    private static func select(_ button: UIButton) {
        button.layer.borderWidth = Constant.CardButton.borderWidthOfSelected
        button.layer.borderColor = Constant.CardButton.borderColorOfSelected
    }
    
}
