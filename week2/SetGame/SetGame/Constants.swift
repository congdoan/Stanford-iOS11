//
//  Constants.swift
//  SetGame
//
//  Created by Cong Doan on 8/20/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

enum Constant {
    static let rowsInRegularHeight = 8
    static let colsInCompactWidth = 3
    
    static let rowsInCompactHeight = 4
    static let colsInRegularWidth = 6

    enum CardShading {
        static let strokeWidthOfOutline: CGFloat = 2
        static let strokeWidthOfSolid: CGFloat = -1
        static let alphaComponentOfStriped: CGFloat = 0.15
    }
    
    enum CardButton {
        static let titleFontSize: CGFloat = 34
        
        static let spacing: CGFloat = 8
        
        static let cornerRadius: CGFloat = 8
        static let borderWidthOfSelected: CGFloat = 2
        static let borderColorOfSelected = UIColor.blue.cgColor
        static let borderWidthOfUnselected: CGFloat = 0.5
        static let borderColorOfUnselected = UIColor.black.withAlphaComponent(0.35).cgColor
    }
    
    enum Score {
        static let match = 3
        static let mismatch = -5
        static let deselect = -1
    }
}
