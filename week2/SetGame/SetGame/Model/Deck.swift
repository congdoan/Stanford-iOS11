//
//  Deck.swift
//  SetGame
//
//  Created by Cong Doan on 8/16/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

class Deck {
    
    static let SET_SIZE = 3
    
    static func isSet(_ cards: [Card]) -> Bool {
        guard cards.count == SET_SIZE else {
            fatalError("Number of cards is Not \(SET_SIZE): \(cards.count)")
        }
        return satisfyRule(for: cards.map { $0.number })
            && satisfyRule(for: cards.map { $0.shape })
            && satisfyRule(for: cards.map { $0.shading })
            && satisfyRule(for: cards.map { $0.color })
    }
    
    private static func satisfyRule<T:Hashable>(for values : [T]) -> Bool {
        let set = Set(values)
        return set.count == 1 || set.count == values.count
    }
    
    var cards = [Card]()
    
    init(shuffle: Bool = true) {
        for number in Card.allNumbers {
            for shape in Card.allShapes {
                for shading in Card.allShadings {
                    for color in Card.allColors {
                        cards.append(Card(number: number, shape: shape, shading: shading, color: color))
                    }
                }
            }
        }
        if shuffle {
            cards.shuffle()
        }
    }
    
    var isEmpty: Bool {
        return cards.isEmpty
    }
    
    func deal(numberOfCards: Int = 3) -> [Card] {
        guard cards.count >= numberOfCards else {
            fatalError("Not enough cards to deal")
        }
        let start = cards.count - numberOfCards
        let dealedCards = Array(cards[start...])
        cards.removeLast(numberOfCards)
        return dealedCards
    }
    
}
