//
//  ConcentrationViewController.swift
//  Concentration
//
//  Created by Cong Doan on 7/4/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class ConcentrationViewController: UIViewController {
    
    private var numberOfPairs: Int {
        return (cardButtons.count + 1) / 2
    }
    //private lazy var game = ConcentrationByMichel(numberOfPairsOfCards: numberOfPairs)
    private lazy var game = Concentration(numberOfPairsOfCards: numberOfPairs)

    var theme = ThemeChooserViewController.randomTheme {
        didSet {
            if oldValue != theme {
                card2Emoji = [:]
                updateViewFromModel()
            }
        }
    }
    //private var emojis: [String]!
    //private lazy var emojis = theme.shuffledSingleCharacterStrings
    private var emojis = [String]()
    private var card2Emoji = [Card: String]()
    
    @IBOutlet private var cardButtons: [UIButton]! {
        didSet {
            updateViewFromModel()
        }
    }
    
    @IBOutlet private weak var scoreLabel: UILabel! {
        didSet {
            refreshScoreLabel()
        }
    }
    private let scoreWordAttrString = NSAttributedString(string: "Score: ", attributes: [.strokeWidth: 4])
    private let scoreNumberAttr: [NSAttributedStringKey: Any] = [.foregroundColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)]

    @IBOutlet private weak var flipCountLabel: UILabel!
    
    @IBAction private func tapCard(_ button: UIButton) {
        guard let cardNumber = cardButtons.index(of: button) else { return }
        let changedCardIndices = game.chooseCard(at: cardNumber)
        for changedCardIndex in changedCardIndices  {
            configureButton(cardButtons[changedCardIndex], with: game.cards[changedCardIndex])
        }
        refreshScoreAndFlipCountLabels()
    }
    
    private func updateViewFromModel() {
        emojis = theme.shuffledSingleCharacterStrings
        if cardButtons == nil {
            return
        }
        for idx in cardButtons.indices {
            configureButton(cardButtons[idx], with: game.cards[idx])
        }
    }
    
    private func configureButton(_ button: UIButton, with card: Card) {
        if card.isFaceUp {
            button.setTitle(emoji(for: card), for: .normal)
            button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            button.setTitle(nil, for: .normal)
            button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        }
    }
    
    private func emoji(for card: Card) -> String {
        if card2Emoji[card] == nil && emojis.count > 0 {
            card2Emoji[card] = emojis.removeLast()
        }
        return card2Emoji[card] ?? "?"
    }
    
    private func refreshScoreAndFlipCountLabels() {
        refreshScoreLabel()
        flipCountLabel.text = "Flips: \(game.flipCount)"
    }
    
    private func refreshScoreLabel() {
        let scoreNumberAttrString = NSAttributedString(string: "\(game.score)", attributes: scoreNumberAttr)
        let scoreAttrString = NSMutableAttributedString(attributedString: scoreWordAttrString)
        scoreAttrString.append(scoreNumberAttrString)
        scoreLabel.attributedText = scoreAttrString
    }
    
    @IBAction private func tapNewGame(_ sender: Any) {
        for cardButton in cardButtons {
            cardButton.setTitle(nil, for: .normal)
            cardButton.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        }
        //game = ConcentrationByMichel(numberOfPairsOfCards: numberOfPairs)
        game = Concentration(numberOfPairsOfCards: numberOfPairs)
        refreshScoreAndFlipCountLabels()
        card2Emoji.removeAll(keepingCapacity: true)
        updateViewFromModel()
    }
    
}

