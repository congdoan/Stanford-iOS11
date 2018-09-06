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
        for idx in subviews.indices {
            let row = CGFloat(idx / cols), col = CGFloat(idx % cols)
            let cardView = subviews[idx]
            cardView.frame = CGRect(x: col * (cardW + spacing), y: row * (cardH + spacing),
                                    width: cardW, height: cardH)
        }
    }
    
}

extension CardContainerView {
    private enum SizeRatio {
        static let cardHeightOverCardWidth: CGFloat = 1.7
        static let cardSpacingOverSqrtCardArea: CGFloat = 0.1
    }
}
