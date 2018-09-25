//
//  CardContainerView.swift
//  GraphicalSetGame
//
//  Created by Cong Doan on 9/4/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class CardContainerView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        populateCardsContainerView()
    }

    private func populateCardsContainerView() {
        let size = bounds.size, w = size.width, h = size.height
        let numCards = subviews.count, a = SizeRatio.cardHeightOverCardWidth
        let cardArea = w * h / CGFloat(numCards)
        var cardW = sqrt(cardArea / a), cardH = a * cardW
        var cols = Int(w / cardW), rows = Int(h / cardH)
        if cols * rows < numCards {
            let remainingW = w - CGFloat(cols) * cardW, remainingH = h - CGFloat(rows) * cardH
            if a * remainingW >= remainingH {
                cols += 1
                rows = numCards / cols + (numCards % cols != 0 ? 1 : 0)
            } else {
                rows += 1
                cols = numCards / rows + (numCards % rows != 0 ? 1 : 0)
            }
        }
        cardW = w / CGFloat(cols)
        cardH = h / CGFloat(rows)
        let spacing = sqrt(cardW * cardH) * SizeRatio.cardSpacingOverSqrtCardArea
        cardW -= CGFloat(cols - 1) * spacing / CGFloat(cols)
        cardH -= CGFloat(rows - 1) * spacing / CGFloat(rows)
        
        let completion: ((UIViewAnimatingPosition) -> Void)?
        if let lastCardView = subviews.last, lastCardView.alpha == 0 {
            completion = { finalPosition in
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 2,
                    delay: 0,
                    options: [.curveLinear],
                    animations: {
                        var index = self.subviews.count - 1
                        while index >= 0 && self.subviews[index].alpha == 0 {
                            self.subviews[index].alpha = 1
                            index -= 1
                        }
                    })
            }
        } else {
            completion = nil
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 2,
            delay: 0,
            options: [],
            animations: {
                for idx in self.subviews.indices {
                    let row = CGFloat(idx / cols), col = CGFloat(idx % cols)
                    let cardView = self.subviews[idx]
                    cardView.frame = CGRect(x: col * (cardW + spacing), y: row * (cardH + spacing),
                                            width: cardW, height: cardH)
                }
            },
            completion: completion)
    }
    
}

extension CardContainerView {
    private enum SizeRatio {
        static let cardHeightOverCardWidth: CGFloat = 1.7
        static let cardSpacingOverSqrtCardArea: CGFloat = 0.1
    }
}
