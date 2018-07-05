//
//  HelperExtensions.swift
//  StanfordiOSClassWeek1
//
//  Created by Cong Doan on 7/5/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import Foundation

extension Int {
    
    var random: Int {
        return Int(arc4random_uniform(UInt32(self)))
    }
    
}

extension Array {
    
    mutating func shuffle() {
        guard self.count > 1 else { return }
        for index in 1..<self.count {
            let randomIndex = (index + 1).random
            self.swapAt(index, randomIndex)
        }
    }
    
}
