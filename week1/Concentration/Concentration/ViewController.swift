//
//  ViewController.swift
//  StanfordiOSClassWeek1
//
//  Created by Cong Doan on 7/4/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var numberOfPairs: Int {
        return (cardButtons.count + 1) / 2
    }
    //private lazy var game = ConcentrationByMichel(numberOfPairsOfCards: numberOfPairs)
    private lazy var game = Concentration(numberOfPairsOfCards: numberOfPairs)

    private static let emojiThemes = ["🐝🐶🐸🦅🐠🦓🐒🐘🦔🕷",
                                      "🎾⚽️🏀🚴‍♀️🏊‍♂️🏓🏋️‍♂️🤺🏹🏑",
                                      "🍏🍎🍐🍊🍋🍌🍉🍇🍓🍈",
                                      "🚗🚕🚙🚌🚎🏎🚓🚑🚒🚐",
                                      "⌚️📱💻⌨️🖥🖨🖲🕹🗜📷",
                                      "🏁🚩🏳️‍🌈🇦🇫🇦🇽🇦🇱🇩🇿🇦🇸🇦🇩🇦🇴"]
    private static func getRandomEmojiTheme() -> [String] {
        var emojiTheme = emojiThemes[emojiThemes.count.arc4random].map { "\($0)" }
        emojiTheme.shuffle()
        return emojiTheme
    }
    
    private var emojiChoices = getRandomEmojiTheme()
    private var card2Emoji = [Card: String]()
    
    @IBOutlet private var cardButtons: [UIButton]!
    
    @IBOutlet private weak var scoreLabel: UILabel!
    
    @IBOutlet private weak var flipCountLabel: UILabel!
    
    @IBAction private func tapCard(_ button: UIButton) {
        guard let cardNumber = cardButtons.index(of: button) else { return }
        let changedCardIndices = game.chooseCard(at: cardNumber)
        for changedCardIndex in changedCardIndices  {
            let button = cardButtons[changedCardIndex]
            let card = game.cards[changedCardIndex]
            if card.isFaceUp {
                button.setTitle(emoji(for: card), for: .normal)
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                button.setTitle(nil, for: .normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            }
        }
        refreshScoreAndFlipCountLabels()
    }
    
    private func emoji(for card: Card) -> String {
        if card2Emoji[card] == nil && emojiChoices.count > 0 {
            card2Emoji[card] = emojiChoices.removeLast()
        }
        return card2Emoji[card] ?? "?"
    }
    
    private func refreshScoreAndFlipCountLabels() {
        scoreLabel.text = "Score: \(game.score)"
        flipCountLabel.text = "Flips: \(game.flipCount)"
    }
    
    @IBAction private func tapNewGame(_ sender: Any) {
        for cardButton in cardButtons {
            cardButton.setTitle(nil, for: .normal)
            cardButton.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        }
        //game = ConcentrationByMichel(numberOfPairsOfCards: numberOfPairs)
        game = Concentration(numberOfPairsOfCards: numberOfPairs)
        refreshScoreAndFlipCountLabels()
        emojiChoices = ViewController.getRandomEmojiTheme()
        card2Emoji.removeAll(keepingCapacity: true)
    }
    
}

