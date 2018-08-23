//
//  RoundedButton.swift
//  Boggle
//
//  Created by Cong Doan on 2/12/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {

    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        cornerRadius = min(bounds.height / 2, 30)
        
        /*
        let fontSizeOverHeight: CGFloat = 18 / 48
        let fontSize = fontSizeOverHeight * bounds.height
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        */
    }

}
