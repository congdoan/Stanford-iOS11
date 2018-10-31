//
//  Concentration.swift
//  StanfordiOSClassWeek1
//
//  Created by Cong Doan on 7/5/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

class Concentration {
    
    private(set) var cards = [Card]()
    
    private let matchScore = 2
    private let mismatchScore = -1
    private var currentlyFacedUpCardIndices = Set<Int>()
    private(set) var score = 0
    private var alreadySeenCardIndices = Set<Int>()
    
    private(set) var flipCount = 0
    
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0, "Concentration.init(numberOfPairsOfCards: \(numberOfPairsOfCards)); Number of pairs must be atleast 1")
        
        for _ in 1...numberOfPairsOfCards {
            let card = Card()
            cards += [card, card]
        }
        cards.shuffle()
    }
    
    func chooseCard(at index: Int) -> Set<Int> {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index); Index must be in \(cards.indices)")
        
        var changedCardIndices = Set<Int>()
        if cards[index].isFaceUp || cards[index].isMatched { return changedCardIndices }
        if currentlyFacedUpCardIndices.count == 1 {
            let matchIndex = Array(currentlyFacedUpCardIndices)[0]
            if cards[matchIndex] == cards[index] {
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

