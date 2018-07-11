//
//  Card.swift
//  StanfordiOSClassWeek1
//
//  Created by Cong Doan on 7/5/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import Foundation

struct Card {
    
    private static var identifierFactory = 0
    
    private static func getIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    var isFaceUp: Bool
    var isMatched: Bool
    let identifier: Int
    
    init(isFaceUp: Bool = false, isMatched: Bool = false) {
        self.isFaceUp = isFaceUp
        self.isMatched = isMatched
        identifier = Card.getIdentifier()
    }
    
}
