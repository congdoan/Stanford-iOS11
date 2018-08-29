//
//  PlayingCard.swift
//  PlayingCard
//
//  Created by Cong Doan on 8/29/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

struct PlayingCard {
    let rank: Rank
    let suit: Suit

    // This enum is badly designed with the intention to demonstrade the use of associated data & 'where' pattern matching
    enum Rank {
        case ace
        case numeric(Int)
        case face(String)
        
        var order: Int {
            switch self {
            case .ace: return 1
            case .numeric(let pips): return pips
            case .face(let kind) where kind == "J": return 11
            case .face(let kind) where kind == "Q": return 12
            case .face(let kind) where kind == "K": return 13
            default: return 0
            }
        }
        
        static var all: [Rank] {
            var allRanks = [Rank.ace]
            for pips in 2...10 {
                allRanks.append(.numeric(pips))
            }
            allRanks += [.face("J"), .face("Q"), .face("K")]
            return allRanks
        }
    }
    
    enum Suit: String {
        case spades = "♠"
        case clubs = "♣"
        case diamons = "♦"
        case hearts = "❤️"
        
        static var all: [Suit] {
            return [.spades, .clubs, .diamons, .hearts]
        }
    }
}
