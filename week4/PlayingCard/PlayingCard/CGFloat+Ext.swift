//
//  CGFloat+Ext.swift
//  PlayingCard
//
//  Created by Cong Doan on 9/8/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import CoreGraphics

extension CGFloat {
    var arc4random: CGFloat {
        return self * (CGFloat(arc4random_uniform(UInt32.max)) / CGFloat(UInt32.max))
    }
}

