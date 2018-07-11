//
//  ConcentrationByMichel.swift
//  Concentration
//
//  Created by Cong Doan on 7/11/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

class ConcentrationByMichel {
    
    private(set) var cards = [Card]()
    
    private let matchScore = 2
    private let mismatchScore = -1
    private(set) var score = 0
    private var alreadySeenCardIndices = Set<Int>()

    private(set) var flipCount = 0
    
    private var indexOfOnlyAndOneFacedUpCard: Int? {
        get {
            var foundIndex: Int?
            for index in cards.indices {
                if cards[index].isFaceUp && !cards[index].isMatched {
                    if foundIndex == nil {
                        foundIndex = index
                    } else {
                        return nil
                    }
                }
            }
            return foundIndex
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0, "ConcentrationByMichel.init(numberOfPairsOfCards: \(numberOfPairsOfCards)); Number of pairs must be atleast 1")
        
        for _ in 1...numberOfPairsOfCards {
            let card = Card()
            cards += [card, card]
        }
        cards.shuffle()
    }
    
    func chooseCard(at pickIndex: Int) -> Set<Int> {
        assert(cards.indices.contains(pickIndex), "ConcentrationByMichel.chooseCard(at: \(pickIndex); Index must be in \(cards.indices)")
        
        var changedCardIndices = Set<Int>()
        if cards[pickIndex].isFaceUp || cards[pickIndex].isMatched { return changedCardIndices }
        
        if let matchIndex = indexOfOnlyAndOneFacedUpCard {
            if cards[matchIndex].identifier == cards[pickIndex].identifier {
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
                if cards[index].isFaceUp {
                    if !cards[index].isMatched {
                        alreadySeenCardIndices.insert(index)
                    }
                    changedCardIndices.insert(index)
                }
            }
            indexOfOnlyAndOneFacedUpCard = pickIndex
        }
        changedCardIndices.insert(pickIndex)

        flipCount += 1
        return changedCardIndices
    }

}
