//
//  Concentration.swift
//  StanfordiOSClassWeek1
//
//  Created by Cong Doan on 7/5/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import Foundation

class Concentration {
    
    var cards = [Card]()
    
    let matchScore = 2
    let mismatchScore = -1
    var currentlyFacedUpCardIndices = Set<Int>()
    var score = 0
    var alreadySeenCardIndices = Set<Int>()
    
    var flipCount = 0
    
    init(numberOfPairsOfCards: Int) {
        for _ in 1...numberOfPairsOfCards {
            let card = Card()
            cards += [card, card]
        }
        cards.shuffle()
    }
    
    func chooseCard(at index: Int) -> Set<Int> {
        var changedCardIndices = Set<Int>()
        if cards[index].isFaceUp || cards[index].isMatched { return changedCardIndices }
        if currentlyFacedUpCardIndices.count == 1 {
            let matchIndex = Array(currentlyFacedUpCardIndices)[0]
            if cards[matchIndex].identifier == cards[index].identifier {
                cards[matchIndex].isMatched = true
                cards[index].isMatched = true
                score += matchScore
            } else {
                if alreadySeenCardIndices.contains(matchIndex) {
                    score += mismatchScore
                }
                if alreadySeenCardIndices.contains(index) {
                    score += mismatchScore
                }
            }
        } else if currentlyFacedUpCardIndices.count > 1 {
            for faceUpCardIndex in currentlyFacedUpCardIndices {
                cards[faceUpCardIndex].isFaceUp = false
                changedCardIndices.insert(faceUpCardIndex)
                alreadySeenCardIndices.insert(faceUpCardIndex)
            }
            currentlyFacedUpCardIndices.removeAll(keepingCapacity: true)
        }
        cards[index].isFaceUp = true
        currentlyFacedUpCardIndices.insert(index)
        changedCardIndices.insert(index)
        flipCount += 1
        return changedCardIndices
    }
    
}

