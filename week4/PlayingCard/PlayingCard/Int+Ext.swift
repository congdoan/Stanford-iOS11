//
//  Int+Ext.swift
//  PlayingCard
//
//  Created by Cong Doan on 8/29/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import Foundation

extension Int {
    var arc4random: Int {
        let nonnegativeRandom = self != 0 ? Int(arc4random_uniform(UInt32(abs(self)))) : 0
        return self >= 0 ? nonnegativeRandom : -nonnegativeRandom
    }
}
