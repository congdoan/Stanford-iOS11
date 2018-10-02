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
    
    private func positionCardViews(_ cols: Int,
                                   _ cardW: CGFloat, _ cardH: CGFloat,
                                   _ spacing: CGFloat) {
        for index in subviews.indices {
            let row = CGFloat(index / cols), col = CGFloat(index % cols)
            subviews[index].frame = CGRect(x: col * (cardW + spacing), y: row * (cardH + spacing),
                                           width: cardW, height: cardH)
        }
    }
    
    func positionCardViews(allCardViewsAreTransparent: Bool) {
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
        if allCardViewsAreTransparent {
            positionCardViews(cols, cardW, cardH, spacing)
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
            if let lastCardView = subviews.last, lastCardView.alpha == 0 {
                var startIndex = subviews.count - 1
                while startIndex >= 0 && subviews[startIndex].alpha == 0 {
                    startIndex -= 1
                }
                let indexRangeOfCardsToBeDealt = startIndex+1..<subviews.count
                
                completion = { finalPosition in
                    var index2Frame = [Int: CGRect]()
                    for index in indexRangeOfCardsToBeDealt {
                        index2Frame[index] = self.subviews[index].frame
                        self.subviews[index].frame = self.dealButtonFrame
                        self.subviews[index].alpha = 1
                    }
                    
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 2,
                        delay: 0,
                        options: [.curveLinear],
                        animations: {
                            for index in indexRangeOfCardsToBeDealt {
                                self.subviews[index].frame = index2Frame[index]!
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
                    self.positionCardViews(cols, cardW, cardH, spacing)
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
