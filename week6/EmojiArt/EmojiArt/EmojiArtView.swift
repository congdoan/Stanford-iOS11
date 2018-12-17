//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Cong Doan on 11/30/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class EmojiArtView: UIView {
    
    var backgroundImage: UIImage? {
        didSet { setNeedsDisplay() }
    }

    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }

}
