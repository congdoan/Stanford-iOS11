//
//  Array+Ext.swift
//  PlayingCard
//
//  Created by Cong Doan on 8/29/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

extension Array {
    mutating func shuffle() {
        guard count > 1 else { return }
        
        for index in 1..<count {
            let randomIndex = (index + 1).arc4random
            let randomElement = self[randomIndex]
            self[randomIndex] = self[index]
            self[index] = randomElement
        }
    }
}
