//
//  EmojiCollectionViewCell.swift
//  EmojiArt
//
//  Created by Cong Doan on 12/17/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
}

extension UICollectionViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
}
