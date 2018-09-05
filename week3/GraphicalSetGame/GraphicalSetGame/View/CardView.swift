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
    
    private var cornerRadius: CGFloat { return bounds.width * SizeRatio.cornerRadiusOverWidth }

    override func draw(_ rect: CGRect) {
        let roundedCornersPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        UIColor.white.setFill()
        roundedCornersPath.fill()
        
        let shapeWidth = bounds.width * SizeRatio.shapeWidthOverWidth
        let shapeHeight = bounds.height * SizeRatio.shapeHeightOverHeight
        let shapesDistance = bounds.height * SizeRatio.shapesDistanceOverHeight
        let totalHeight = CGFloat(number) * shapeHeight + CGFloat(number - 1) * shapesDistance
        let origin = CGPoint(x: bounds.midX - shapeWidth/2, y: bounds.midY - totalHeight/2)
        var  shapeBounds = CGRect(origin: origin, size: CGSize(width: shapeWidth, height: shapeHeight))
        let combinedPath = UIBezierPath()
        for _ in 1...number {
            combinedPath.append(createShapePath(in: shapeBounds))
            shapeBounds.origin.y += (shapeHeight + shapesDistance)
        }
        let totalBounds = CGRect(origin: origin, size: CGSize(width: shapeWidth, height: totalHeight))
        drawPath(combinedPath, in: totalBounds)
    }
    
    private func drawPath(_ path: UIBezierPath, in bounds: CGRect) {
        switch fillingKind {
        case .none:
            path.lineWidth = bounds.width * SizeRatio.outlinedWidthOverShapeWidth
            color.setStroke()
            path.stroke()
        case .solid:
            color.setFill()
            path.fill()
        case .striped:
            color.setStroke()
            path.lineWidth = bounds.width * SizeRatio.outlinedWidthOverShapeWidth
            path.stroke()
            path.addClip()
            let numberOfStrips = Int(bounds.width * SizeRatio.numberOfStripsOverShapeWidth)
            for stripeNumber in 1...numberOfStrips {
                let x = bounds.minX + bounds.width * CGFloat(stripeNumber) / CGFloat(numberOfStrips + 1)
                path.move(to: CGPoint(x: x, y: bounds.minY))
                path.addLine(to: CGPoint(x: x, y: bounds.maxY))
            }
            path.lineWidth = path.lineWidth * SizeRatio.stripedWidthOverOutlinedWidth
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
    var isSelected: Bool {
        get {
            return layer.cornerRadius != 0
        }
        set {
            if newValue {
                layer.borderWidth = max(min(bounds.width * bounds.height * SizeRatio.borderWidthOverArea,
                                            SizeRatio.maxBorderWidth),
                                        SizeRatio.minBorderWidth)
                layer.cornerRadius = cornerRadius
                layer.borderColor = #colorLiteral(red: 0.1176470588, green: 0.09411764706, blue: 0.1137254902, alpha: 1)
            } else {
                layer.borderWidth = 0
                layer.cornerRadius = 0
                layer.borderColor = nil
            }
        }
    }
    
    private enum SizeRatio {
        static let shapeWidthOverWidth: CGFloat = 112/165  //102/165
        static let shapeHeightOverHeight: CGFloat = 61/262 //52/262
        static let shapesDistanceOverHeight: CGFloat = 16/262
        
        static let outlinedWidthOverShapeWidth: CGFloat = 3/108
        static let stripedWidthOverOutlinedWidth: CGFloat = 0.8/2
        static let numberOfStripsOverShapeWidth: CGFloat = 26/108

        static let cornerRadiusOverWidth: CGFloat = 1/20
        
        static let borderWidthOverArea: CGFloat = 2.92082033080672/7328.71574129429
        static let maxBorderWidth: CGFloat = 12.5
        static let minBorderWidth: CGFloat = 1.3
    }
}
