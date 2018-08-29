//
//  PlayingCardDeck.swift
//  PlayingCard
//
//  Created by Cong Doan on 8/29/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import Foundation

struct PlayingCardDeck {
    private(set) var cards = [PlayingCard]()
    
    init() {
        for rank in PlayingCard.Rank.all {
            for suit in PlayingCard.Suit.all {
                cards.append(PlayingCard(rank: rank, suit: suit))
            }
        }
        cards.shuffle()
    }
    
    mutating func draw() -> PlayingCard? {
        return cards.isEmpty ? nil : cards.removeLast()
    }
}
