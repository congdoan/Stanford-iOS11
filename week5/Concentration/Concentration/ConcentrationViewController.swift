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
    private lazy var game = Concentration(numberOfPairsOfCards: numberOfPairs)

    //var theme = ThemeChooserViewController.randomTheme {
    var theme: String? {
        didSet {
            if oldValue != theme {
                initializeEmojiArray()
            }
        }
    }
    //private var emojis: [String]!
    //private lazy var emojis = theme.shuffledSingleCharacterStrings
    private var emojis = [String]()
    private var card2Emoji = [Card: String]()
    
    @IBOutlet private var cardButtons: [UIButton]! {
        didSet {
            initializeEmojiArray()
        }
    }
    
    private var visibleCardButtons: [UIButton] {
        return cardButtons.filter { !$0.superview!.isHidden }
    }
    
    @IBOutlet private weak var scoreLabel: UILabel! {
        didSet {
            refreshScoreLabel()
        }
    }
    private let scoreWordAttrString = NSAttributedString(string: "Score", attributes: [.strokeWidth: 4])
    private let scoreNumberAttr: [NSAttributedStringKey: Any] = [.foregroundColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)]

    @IBOutlet private weak var flipCountLabel: UILabel!
    
    @IBAction private func tapCard(_ button: UIButton) {
        guard let cardNumber = visibleCardButtons.index(of: button) else { return }
        game.chooseCard(at: cardNumber)
        updateViewFromModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        if cardButtons == nil { // Segue prep occurs Before Outlet set
            return
        }
        for idx in visibleCardButtons.indices {
            configureButton(visibleCardButtons[idx], with: game.cards[idx])
        }
        refreshScoreAndFlipCountLabels()
    }
    
    private func initializeEmojiArray() {
        emojis = (theme ?? ThemeChooserViewController.randomTheme).shuffledSingleCharacterStrings
        card2Emoji = [:]
        
        updateViewFromModel()
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
        if card2Emoji[card] == nil {
            card2Emoji[card] = emojis.removeLast()
        }
        return card2Emoji[card]!
    }
    
    private func refreshScoreAndFlipCountLabels() {
        if scoreLabel == nil || flipCountLabel == nil { return }
        
        refreshScoreLabel()
        flipCountLabel.text = "Flips: \(game.flipCount)"
    }
    
    private func refreshScoreLabel() {
        let scoreAttrString = NSMutableAttributedString(attributedString: scoreWordAttrString)
        if traitCollection.verticalSizeClass == .compact {
            let newLine = NSAttributedString(string: "\n")
            scoreAttrString.append(newLine)
        } else {
            let colon = NSAttributedString(string: ": ")
            scoreAttrString.append(colon)
        }
        let scoreNumberAttrString = NSAttributedString(string: "\(game.score)", attributes: scoreNumberAttr)
        scoreAttrString.append(scoreNumberAttrString)
        scoreLabel.attributedText = scoreAttrString
    }
    
    @IBAction private func tapNewGame(_ sender: Any) {
        for cardButton in cardButtons {
            cardButton.setTitle(nil, for: .normal)
            cardButton.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        }
        game = Concentration(numberOfPairsOfCards: numberOfPairs)
        refreshScoreAndFlipCountLabels()
        initializeEmojiArray()
    }
    
}

