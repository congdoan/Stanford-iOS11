//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Cong Doan on 8/27/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

@IBDesignable
class PlayingCardView: UIView {
    
    @IBInspectable
    var rank: Int = 7 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    private var rankString: String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
    
    @IBInspectable
    var suit: String = "♣︎"
    
    @IBInspectable
    var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    var faceCardScale = SizeRatio.faceCardImageSizeToBoundsSize { didSet { setNeedsDisplay() } }
    
    @objc func adjustFaceCardScale(byHandlingPinchRecognizedBy recognizer: UIPinchGestureRecognizer) {
        guard rank > 10 && isFaceUp else { return }
        if [UIGestureRecognizerState.changed, .ended].contains(recognizer.state) {
            faceCardScale *= recognizer.scale
            recognizer.scale = 1
        }
    }
    
    private lazy var upperLeftCornerLabel = createCornerLabel()
    private lazy var lowerRightCornerLabel = createCornerLabel()

    private var cornerFontSize: CGFloat {
        return SizeRatio.cornerFontSizeToBoundsHeight * bounds.height
    }
    
    private var cornerAttributedString: NSAttributedString {
        return centeredAttributedString(rankString + "\n" + suit, fontSize: cornerFontSize)
    }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        
        if isFaceUp {
            if let faceCardImage = UIImage(named: rankString + suit) {
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
            } else {
                drawPips()
            }
        } else {
            let cardbackImage = UIImage(named: "cardback", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection)!
            cardbackImage.draw(in: bounds)
        }
    }
    
    private func drawPips() {
        let pipsPerRowForRank = [ [0], [1], [1,1], [1,1,1], [2,2], [2,1,2], [2,2,2], [2,1,2,2], [2,2,2,2], [2,2,1,2,2], [2,2,2,2,2] ]
        
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            //let maxVerticalPipCount = pipsPerRowForRank.map{$0.count}.max()!
            let maxVerticalPipCount = pipsPerRowForRank.reduce(0) { max($1.count, $0) }
            //let maxHorizontalPipCount = pipsPerRowForRank.map{$0.max()!}.max()!
            let maxHorizontalPipCount = pipsPerRowForRank.reduce(0) { max($1.max()!, $0) } //max($1.max() ?? 0, $0)
            let verticalPipRowSpacing = pipRect.height / CGFloat(maxVerticalPipCount)
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkFontSize = (verticalPipRowSpacing * verticalPipRowSpacing) / attemptedPipString.size().height
            let probablyOkPipString = centeredAttributedString(suit, fontSize: probablyOkFontSize)
            let maxPipStringWidth = pipRect.width / CGFloat(maxHorizontalPipCount)
            if probablyOkPipString.size().width > maxPipStringWidth {
                let fontSize = (probablyOkFontSize * maxPipStringWidth) / probablyOkPipString.size().width
                return centeredAttributedString(suit, fontSize: fontSize)
            } else {
                return probablyOkPipString
            }
        }
        
        guard pipsPerRowForRank.indices.contains(rank) else { return }
        let pipsPerRow = pipsPerRowForRank[rank]
        /*
        var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset)
                            .insetBy(dx: upperLeftCornerLabel.frame.width, dy: upperLeftCornerLabel.frame.height / 2)
        */
        let cornerAttributedStringSize = cornerAttributedString.size()
        var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset)
                            .insetBy(dx: cornerAttributedStringSize.width, dy: cornerAttributedStringSize.height / 2)
        let pipString = createPipString(thatFits: pipRect)
        let pipRowSpacing = pipRect.height / CGFloat(pipsPerRow.count)
        pipRect.size.height = pipString.size().height
        pipRect.origin.y += (pipRowSpacing - pipRect.height) / 2
        for pipCount in pipsPerRow {
            switch pipCount {
            case 1:
                pipString.draw(in: pipRect)
            case 2:
                pipString.draw(in: pipRect.leftHalf)
                pipString.draw(in: pipRect.rightHalf)
            default:
                break
            }
            pipRect.origin.y += pipRowSpacing
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setVisibilityOfCornerLabels()
        
        guard isFaceUp else { return }
        
        let cornerAttributedString = self.cornerAttributedString
        
        configureCornerLabel(upperLeftCornerLabel, cornerAttributedString: cornerAttributedString)
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetedBy(dx: cornerOffset, dy: cornerOffset)

        configureCornerLabel(lowerRightCornerLabel, cornerAttributedString: cornerAttributedString)
        lowerRightCornerLabel.frame.origin = bounds.lowerRight.offsetedBy(dx: -(lowerRightCornerLabel.frame.width + cornerOffset),
                                                                          dy: -(lowerRightCornerLabel.frame.height + cornerOffset))
        lowerRightCornerLabel.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi)
    }
    
    private func setVisibilityOfCornerLabels() {
        upperLeftCornerLabel.isHidden = !isFaceUp
        lowerRightCornerLabel.isHidden = !isFaceUp
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
    }
    
    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configureCornerLabel(_ label: UILabel, cornerAttributedString: NSAttributedString) {
        label.attributedText = cornerAttributedString
        label.frame.size = .zero
        label.sizeToFit()
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        if #available(iOS 11.0, *) {
            font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        }
        let centerParagraphStyle = NSMutableParagraphStyle()
        centerParagraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.font: font, .paragraphStyle: centerParagraphStyle])
    }
    
    private var cornerRadius: CGFloat {
        return SizeRatio.cornerRadiusToBoundsHeight * bounds.height
    }
    
    private var cornerOffset: CGFloat {
        return SizeRatio.cornerOffsetToCornerRadius * cornerRadius
    }
    
}

extension PlayingCardView {
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    var lowerRight: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
    
    func zoom(by zoomFactor: CGFloat) -> CGRect {
        let zoomedWidth = width * zoomFactor, zoomedHeight = height * zoomFactor
        let originX = origin.x + (width - zoomedWidth) / 2
        let originY = origin.y + (height - zoomedHeight) / 2
        return CGRect(x: originX, y: originY, width: zoomedWidth, height: zoomedHeight)
    }
    
    var leftHalf: CGRect {
        return CGRect(origin: origin, size: CGSize(width: width / 2, height: height))
    }
    
    var rightHalf: CGRect {
        return CGRect(x: midX, y: origin.y, width: width / 2, height: height)
    }
}

extension CGPoint {
    func offsetedBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}
