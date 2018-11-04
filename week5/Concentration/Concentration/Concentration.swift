//
//  ConcentrationByMichel.swift
//  Concentration
//
//  Created by Cong Doan on 7/11/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

class Concentration {
    
    private(set) var cards = [Card]()
    
    private let matchScore = 2
    private let mismatchScore = -1
    private(set) var score = 0
    private var alreadySeenCardIndices = Set<Int>()

    private(set) var flipCount = 0
    
    private var indexOfOneAndOnlyFacedUpCard: Int? {
        get {
            let facedUpUnmatchedIndices = cards.indices.filter { cards[$0].isFaceUp && !cards[$0].isMatched }
            return facedUpUnmatchedIndices.oneAndOnly
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0,
               "ConcentrationByMichel.init(numberOfPairsOfCards: \(numberOfPairsOfCards)); Number of pairs must be atleast 1")
        
        for _ in 1...numberOfPairsOfCards {
            let card = Card()
            cards += [card, card]
        }
        cards.shuffle()
    }
    
    func chooseCard(at pickIndex: Int) {
        assert(cards.indices.contains(pickIndex),
               "ConcentrationByMichel.chooseCard(at: \(pickIndex); Index must be in \(cards.indices)")
        
        if cards[pickIndex].isFaceUp || cards[pickIndex].isMatched { return }
        
        if let matchIndex = indexOfOneAndOnlyFacedUpCard {
            assert(matchIndex != pickIndex)
            
            if cards[matchIndex] == cards[pickIndex] {
                cards[matchIndex].isMatched = true
                cards[pickIndex].isMatched = true
                score += matchScore
            } else {
                if alreadySeenCardIndices.contains(matchIndex) {
                    score += mismatchScore
                }
                if alreadySeenCardIndices.contains(pickIndex) {
                    score += mismatchScore
                }
            }
            cards[pickIndex].isFaceUp = true
        } else {
            for index in cards.indices {
                if cards[index].isFaceUp && !cards[index].isMatched {
                    alreadySeenCardIndices.insert(index)
                }
            }
            indexOfOneAndOnlyFacedUpCard = pickIndex
        }

        flipCount += 1
    }

}

extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}

