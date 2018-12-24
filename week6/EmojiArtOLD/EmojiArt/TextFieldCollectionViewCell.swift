//
//  TextFieldCollectionViewCell.swift
//  EmojiArt
//
//  Created by Cong Doan on 12/19/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell {
    
    var resignationHandler: (() -> Void)?
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    override class var identifier: String {
        return "EmojiInputCell"
    }

}

extension TextFieldCollectionViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }
    
}
