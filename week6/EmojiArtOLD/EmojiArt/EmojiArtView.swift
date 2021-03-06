//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Cong Doan on 11/30/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class EmojiArtView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addInteraction(UIDropInteraction(delegate: self))
    }
    
    var backgroundImage: UIImage? {
        didSet { setNeedsDisplay() }
    }

    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
    
    weak var delegate: EmojiArtViewDelegate?

}

extension EmojiArtView: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        let dropPoint = session.location(in: self)
        session.loadObjects(ofClass: NSAttributedString.self) { providers in
            for attributedString in (providers as? [NSAttributedString] ?? []) {
                self.addLabel(with: attributedString, centeredAt: dropPoint)
            }
            
            self.delegate?.emojiArtViewDidChange()
        }
    }
    
    func addLabel(with attributedString: NSAttributedString, centeredAt point: CGPoint) {
        let label = UILabel()
        label.backgroundColor = .clear
        label.attributedText = attributedString
        label.sizeToFit()
        label.center = point
        addEmojiArtGestureRecognizers(to: label)
        addSubview(label)
    }
    
}

protocol EmojiArtViewDelegate: class {
    func emojiArtViewDidChange()
}
