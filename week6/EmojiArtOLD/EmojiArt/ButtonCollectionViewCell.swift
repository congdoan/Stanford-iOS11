//
//  ButtonCollectionViewCell.swift
//  EmojiArt
//
//  Created by Cong Doan on 12/19/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class ButtonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var button: UIButton!
    
    override class var identifier: String {
        return "AddEmojiButtonCell"
    }
    
}
