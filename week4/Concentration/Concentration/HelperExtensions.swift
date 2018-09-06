//
//  HelperExtensions.swift
//  StanfordiOSClassWeek1
//
//  Created by Cong Doan on 7/5/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import Foundation

extension Int {
    
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(-self)))
        }
        return 0
    }
    
}

extension Array {
    
    mutating func shuffle() {
        guard self.count > 1 else { return }
        for index in 1..<self.count {
            let randomIndex = (index + 1).arc4random
            self.swapAt(index, randomIndex)
        }
    }
    
    var randomElement: Element? {
        return !isEmpty ? self[count.arc4random] : nil
    }
    
}
