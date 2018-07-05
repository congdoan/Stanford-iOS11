//
//  ViewController.swift
//  StanfordiOSClassWeek1
//
//  Created by Cong Doan on 7/4/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var game = Concentration(numberOfPairsOfCards: (cardButtons.count + 1) / 2)
    
    static let emojiThemes = [["🐝", "🐶", "🐸", "🦅", "🐠", "🦓", "🐒", "🐘", "🦔", "🕷"],
                              ["🎾", "⚽️", "🏀", "🚴‍♀️", "🏊‍♂️", "🏓", "🏋️‍♂️", "🤺", "🏹", "🏑"],
                              ["🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🍈"],
                              ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎", "🚓", "🚑", "🚒", "🚐"],
                              ["⌚️", "📱", "💻", "⌨️", "🖥", "🖨", "🖲", "🕹", "🗜", "📷"],
                              ["🏁", "🚩", "🏳️‍🌈", "🇦🇫", "🇦🇽", "🇦🇱", "🇩🇿", "🇦🇸", "🇦🇩", "🇦🇴"]]
    static func getRandomEmojiTheme() -> [String] {
        var emojiTheme = emojiThemes[emojiThemes.count.random]
        emojiTheme.shuffle()
        return emojiTheme
    }
    
    var emojiChoices = getRandomEmojiTheme()
    var cardId2Emoji = [Int: String]()
    
    @IBOutlet var cardButtons: [UIButton]!
    
    @IBOutlet var scoreLabel: UILabel!
    
    @IBOutlet weak var flipCountLabel: UILabel!
    
    @IBAction func tapCard(_ button: UIButton) {
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
    
    func emoji(for card: Card) -> String {
        if cardId2Emoji[card.identifier] == nil && emojiChoices.count > 0 {
            cardId2Emoji[card.identifier] = emojiChoices.removeLast()
        }
        return cardId2Emoji[card.identifier] ?? "?"
    }
    
    func refreshScoreAndFlipCountLabels() {
        scoreLabel.text = "Score: \(game.score)"
        flipCountLabel.text = "Flips: \(game.flipCount)"
    }
    
    @IBAction func tapNewGame(_ sender: Any) {
        for cardButton in cardButtons {
            cardButton.setTitle(nil, for: .normal)
            cardButton.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        }
        game = Concentration(numberOfPairsOfCards: (cardButtons.count + 1) / 2)
        refreshScoreAndFlipCountLabels()
        emojiChoices = ViewController.getRandomEmojiTheme()
        cardId2Emoji.removeAll(keepingCapacity: true)
    }
    
}

