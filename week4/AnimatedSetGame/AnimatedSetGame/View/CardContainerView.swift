//
//  CardContainerView.swift
//  GraphicalSetGame
//
//  Created by Cong Doan on 9/4/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class CardContainerView: UIView {
    
    var dealButtonFrame: CGRect!
    
    private func positionCardViews<S: Sequence>(_ indexSequence: S,
                                   _ cols: Int,
                                   _ cardW: CGFloat, _ cardH: CGFloat,
                                   _ spacing: CGFloat) where S.Element == Int {
        for index in indexSequence {
            let row = CGFloat(index / cols), col = CGFloat(index % cols)
            subviews[index].frame = CGRect(x: col * (cardW + spacing), y: row * (cardH + spacing),
                                           width: cardW, height: cardH)
        }
    }
    
    func positionCardViews(numberOfTransparentCardViewsInTheEnd: Int) {
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
        if numberOfTransparentCardViewsInTheEnd == subviews.count {
            positionCardViews(subviews.indices, cols, cardW, cardH, spacing)
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 2,
                delay: 0,
                options: [.curveLinear],
                animations: {
                    for cardView in self.subviews {
                        cardView.alpha = 1
                    }
                })
        } else {
            let completion: ((UIViewAnimatingPosition) -> Void)?
            let indexRangeOfOpaqueCardViews: CountableRange<Int>
            if numberOfTransparentCardViewsInTheEnd > 0 {
                let indexRangeOfTransparentCardViewsToBeDealt = subviews.indices.suffix(numberOfTransparentCardViewsInTheEnd)
                
                completion = { finalPosition in
                    for index in indexRangeOfTransparentCardViewsToBeDealt {
                        self.subviews[index].frame = self.dealButtonFrame
                        self.subviews[index].alpha = 1
                    }
                    
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 2,
                        delay: 0,
                        options: [.curveLinear],
                        animations: {
                            self.positionCardViews(indexRangeOfTransparentCardViewsToBeDealt, cols, cardW, cardH, spacing)
                        })
                }
                indexRangeOfOpaqueCardViews = subviews.indices.prefix(upTo: subviews.count - numberOfTransparentCardViewsInTheEnd)
            } else {
                completion = nil
                indexRangeOfOpaqueCardViews = subviews.indices
            }
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 2,
                delay: 0,
                options: [],
                animations: {
                    self.positionCardViews(indexRangeOfOpaqueCardViews, cols, cardW, cardH, spacing)
                },
                completion: completion)
        }
    }
    
}

extension CardContainerView {
    private enum SizeRatio {
        static let cardHeightOverCardWidth: CGFloat = 1.7
        static let cardSpacingOverSqrtCardArea: CGFloat = 0.1
    }
}
