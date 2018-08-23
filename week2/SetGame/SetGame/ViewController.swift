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
    private var deck = Deck()
    private lazy var cards = deck.deal(numberOfCards: numberOfCardsToStart)

    @IBOutlet weak var verticalStackView: UIStackView!
    
    private var cardButtons: [UIButton]!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    private var rows: Int!, cols: Int!
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        updateRows(verticalSizeClass: newCollection.verticalSizeClass)
    }
    
    private func updateRows(verticalSizeClass: UIUserInterfaceSizeClass) {
        rows = verticalSizeClass == .regular ? Constant.rowsInRegularHeight : Constant.rowsInCompactHeight
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        handleViewSizeChange(newSize: size)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if verticalStackView.subviews.isEmpty {
            updateRows(verticalSizeClass: traitCollection.verticalSizeClass)
            handleViewSizeChange(newSize: view.bounds.size)
        }
    }
    
    private func handleViewSizeChange(newSize: CGSize) {
        cols = newSize.width >= Constant.iPhone4sLargerDimension ? 6 : 3
        
        verticalStackView.removeAllSubviews()
        cardButtons = populateVerticalStackView(newSize: newSize)
        
        for matchedIdx in hiddenMatchedCardIndices {
            cardButtons[matchedIdx].alpha = 0
        }

        for idx in 0..<cards.count {
            if cardButtons[idx].alpha == 0 { continue }
            ViewController.setAttributedTitle(of: cardButtons[idx], basedOn: cards[idx])
        }
        
        for idx in cards.count..<cardButtons.count {
            cardButtons[idx].alpha = 0
        }
        
        for selectedIdx in selectedCardIndices {
            ViewController.select(cardButtons[selectedIdx])
        }
    }
    
    private func populateVerticalStackView(newSize: CGSize) -> [UIButton] {
        var cardButtons = [UIButton]()
        
        let fontSize = Constant.CardButton.titleFontSizeOverButtonWidth
                        * ((newSize.width - (CGFloat(cols + 1) * Constant.CardButton.spacing)) / CGFloat(cols))
        for row in 0..<rows {
            let horizontalStackView = UIStackView()
            horizontalStackView.axis = .horizontal
            horizontalStackView.spacing = Constant.CardButton.spacing
            horizontalStackView.distribution = .fillEqually
            for col in 0..<cols {
                let button = UIButton()
                button.tag = row * cols + col
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
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
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

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
                updateEnabledStatusOfDealButton()
            }
        } else {
            selectedCardIndices.remove(at: selectedCardIndices.index(of: btnIdx)!)
            score += Constant.Score.deselect
        }
    }
    
    @IBOutlet weak var dealButton: UIButton!/* {
        didSet {
            let titleLabel = dealButton.titleLabel!
            titleLabel.minimumScaleFactor = 0.3
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.baselineAdjustment = .alignCenters
        }
    }*/
    @IBAction func onDealButtonTap(_ sender: Any) {
        if selectedCardIndices.count == Deck.SET_SIZE && areSelectedCardsASet {
            replaceWith(deck.deal())
            selectedCardIndices = []
        } else {
            addWith(deck.deal())
        }
        updateEnabledStatusOfDealButton()
    }
    
    @IBAction func onNewGameButtonTap(_ sender: Any) {
        deck = Deck()
        cards = deck.deal(numberOfCards: numberOfCardsToStart)
        selectedCardIndices = []
        hiddenMatchedCardIndices = []
        score = 0
        dealButton.isEnabled = true
        
        handleViewSizeChange(newSize: view.bounds.size)
    }
    
    private func updateEnabledStatusOfDealButton() {
        dealButton.isEnabled = !deck.isEmpty
                                && (selectedCardIndices.count == Deck.SET_SIZE && areSelectedCardsASet
                                    || cards.count < cardButtons.count)
    }
    
    private func onTapWhen3CardsSelected(_ tappedButtonIndex: Int) {
        if areSelectedCardsASet {
            if deck.isEmpty {
                hideSETOfSelectedCards()
            } else {
                replaceWith(deck.deal(), completion: updateEnabledStatusOfDealButton)
            }
            selectedCardIndices = selectedCardIndices.contains(tappedButtonIndex) ? [] : [tappedButtonIndex]
            for selectedIdx in selectedCardIndices {
                ViewController.select(cardButtons[selectedIdx])
            }
            updateEnabledStatusOfDealButton()
        } else {
            for selectedIdx in selectedCardIndices {
                ViewController.deselect(cardButtons[selectedIdx])
            }
            ViewController.select(cardButtons[tappedButtonIndex])
            selectedCardIndices = [tappedButtonIndex]
        }
    }
    
    private var hiddenMatchedCardIndices = [Int]()
    private func hideSETOfSelectedCards() {
        hiddenMatchedCardIndices.append(contentsOf: selectedCardIndices)
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
