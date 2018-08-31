//
//  CardView.swift
//  GraphicalSetGame
//
//  Created by Cong Doan on 8/30/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {
    
    enum Filling: Int {
        case none, solid, striped
    }
    
    enum Shape: Int {
        case diamon, oval, squiggle
    }
    
    @IBInspectable
    var number: Int = 2 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var color: UIColor = .purple { didSet { setNeedsDisplay() } }
    
    var fillingKind: Filling = .none { didSet { setNeedsDisplay() } }
    
    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'fillingKind' instead.")
    @IBInspectable var fillingAsInt: Int = 0 {
        willSet(fillingKindIndex) {
            fillingKind = Filling(rawValue: fillingKindIndex) ?? .none
        }
    }

    var shape: Shape = .diamon { didSet { setNeedsDisplay() } }
    
    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'shape' instead.")
    @IBInspectable var shapeAsInt: Int = 0 {
        willSet(shapeIndex) {
            shape = Shape(rawValue: shapeIndex) ?? .diamon
        }
    }

    private var shapeSizeScale: CGFloat = 1 { didSet { setNeedsDisplay() } }

    @IBAction func onPinchRecognizedBy(_ recognizer: UIPinchGestureRecognizer) {
        guard recognizer.state == .ended else  {return }
        shapeSizeScale = recognizer.scale
        recognizer.scale = 1
    }
    
    override func draw(_ rect: CGRect) {
        let roundedCornersPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width * SizeRatio.cornerRadiusOverWidth)
        UIColor.white.setFill()
        roundedCornersPath.fill()
        
        let shapeWidth = bounds.width * SizeRatio.shapeWidthOverCardWidth
        let shapeHeight = bounds.height * SizeRatio.shapeHeightOverCardHeight
        let shapesDistance = bounds.height * SizeRatio.shapesDistanceOverCardHeight
        let totalHeight = CGFloat(number) * shapeHeight + CGFloat(number - 1) * shapesDistance
        var  shapeBounds = CGRect(origin: CGPoint(x: bounds.midX - shapeWidth/2, y: bounds.midY - totalHeight/2),
                                  size: CGSize(width: shapeWidth, height: shapeHeight)).zoomed(by: shapeSizeScale)
        let drawingContext = fillingKind == .striped ? UIGraphicsGetCurrentContext()! : nil
        for _ in 1...number {
            drawShape(in: shapeBounds)
            drawingContext?.resetClip()
            shapeBounds.origin.y += (shapeHeight + shapesDistance) * shapeSizeScale
        }
    }
    
    private func drawShape(in bounds: CGRect) {
        let path = createShapePath(in: bounds)
        switch fillingKind {
        case .none:
            path.lineWidth = bounds.height * SizeRatio.outlinedLineWidthOverCardHeight
            color.setStroke()
            path.stroke()
        case .solid:
            color.setFill()
            path.fill()
        case .striped:
            color.setStroke()
            path.lineWidth = bounds.height * SizeRatio.outlinedLineWidthOverCardHeight
            path.stroke()
            path.addClip()
            let numberOfStrips = 20
            for stripeNumber in 1...numberOfStrips {
                let x = bounds.minX + bounds.width * CGFloat(stripeNumber) / CGFloat(numberOfStrips + 1)
                path.move(to: CGPoint(x: x, y: bounds.minY))
                path.addLine(to: CGPoint(x: x, y: bounds.maxY))
            }
            path.lineWidth = path.lineWidth * SizeRatio.stripedLineWidthOverOutlinedLineWidth
            path.stroke()
        }
    }
    
    private func createShapePath(in bounds: CGRect) -> UIBezierPath {
        switch shape {
        case .diamon:
            return createDiamonPath(in: bounds)
        case .oval:
            return UIBezierPath(ovalIn: bounds)
        case .squiggle:
            return createSquigglePath(in: bounds)
        }
    }
    
    private func createDiamonPath(in bounds: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.midX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.midY))
        path.close()
        return path
    }

    private func createSquigglePath(in bounds: CGRect) -> UIBezierPath {
        let width = bounds.width, height = bounds.height
        let minX = bounds.minX, minY = bounds.minY

        let path = UIBezierPath()
        path.move(to: CGPoint(x: minX + width*0.05, y: minY + height*0.40))
        path.addCurve(to: CGPoint(x: minX + width*0.35, y: minY + height*0.25),
                      controlPoint1: CGPoint(x: minX + width*0.09, y: minY + height*0.15),
                      controlPoint2: CGPoint(x: minX + width*0.18, y: minY + height*0.10))
        path.addCurve(to: CGPoint(x: minX + width*0.75, y: minY + height*0.30),
                      controlPoint1: CGPoint(x: minX + width*0.40, y: minY + height*0.30),
                      controlPoint2: CGPoint(x: minX + width*0.60, y: minY + height*0.45))
        path.addCurve(to: CGPoint(x: minX + width*0.97, y: minY + height*0.35),
                      controlPoint1: CGPoint(x: minX + width*0.87, y: minY + height*0.15),
                      controlPoint2: CGPoint(x: minX + width*0.98, y: minY + height*0.00))
        path.addCurve(to: CGPoint(x: minX + width*0.45, y: minY + height*0.85),
                      controlPoint1: CGPoint(x: minX + width*0.95, y: minY + height*1.10),
                      controlPoint2: CGPoint(x: minX + width*0.50, y: minY + height*0.95))
        path.addCurve(to: CGPoint(x: minX + width*0.25, y: minY + height*0.85),
                      controlPoint1: CGPoint(x: minX + width*0.40, y: minY + height*0.80),
                      controlPoint2: CGPoint(x: minX + width*0.35, y: minY + height*0.75))
        path.addCurve(to: CGPoint(x: minX + width*0.05, y: minY + height*0.40),
                      controlPoint1: CGPoint(x: minX + width*0.00, y: minY + height*1.10),
                      controlPoint2: CGPoint(x: minX + width*0.005, y: minY + height*0.60))
        path.close()
        return path
    }
    
}

extension CardView {
    private enum SizeRatio {
        static let shapeWidthOverCardWidth: CGFloat = 102/165
        static let shapeHeightOverCardHeight: CGFloat = 52/262
        static let shapesDistanceOverCardHeight: CGFloat = 16/262
        
        static let outlinedLineWidthOverCardHeight: CGFloat = 2/88.75
        static let stripedLineWidthOverOutlinedLineWidth: CGFloat = 0.45/2
        
        static let cornerRadiusOverWidth: CGFloat = 1/20
    }
}

extension CGRect {
    func zoomed(by scale: CGFloat) -> CGRect {
        let zoomedWidth = width * scale, zoomedHeight = height * scale
        return CGRect(x: origin.x + (width - zoomedWidth) / 2, y: origin.y + (height - zoomedHeight) / 2,
                      width: zoomedWidth, height: zoomedHeight)
    }
}
