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
        case diamond, oval, squiggle
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

    var shape: Shape = .diamond { didSet { setNeedsDisplay() } }
    
    init() {
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        number = aDecoder.decodeInteger(forKey: "number")
        color = aDecoder.decodeObject(forKey: "color") as! UIColor
        let fillingKindRaw = aDecoder.decodeInteger(forKey: "fillingKindRaw")
        fillingKind = Filling(rawValue: fillingKindRaw)!
        let shapeRaw = aDecoder.decodeInteger(forKey: "shapeRaw")
        shape = Shape(rawValue: shapeRaw)!
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        
        aCoder.encode(number, forKey: "number")
        aCoder.encode(color, forKey: "color")
        aCoder.encode(fillingKind.rawValue, forKey: "fillingKindRaw")
        aCoder.encode(shape.rawValue, forKey: "shapeRaw")
    }
    
    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'shape' instead.")
    @IBInspectable var shapeAsInt: Int = 0 {
        willSet(shapeIndex) {
            shape = Shape(rawValue: shapeIndex) ?? .diamond
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                layer.borderWidth = sqrt(bounds.width * bounds.height) * SizeRatio.borderWidthOverSqrtArea
                layer.cornerRadius = cornerRadius
                layer.borderColor = #colorLiteral(red: 0.1176470588, green: 0.09411764706, blue: 0.1137254902, alpha: 1)
            } else {
                layer.borderWidth = 0
                layer.cornerRadius = 0
                layer.borderColor = nil
            }
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
        case .diamond:
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
        static let shapeWidthOverWidth: CGFloat = 112/165
        static let shapeHeightOverHeight: CGFloat = 61/262
        static let shapesDistanceOverHeight: CGFloat = 16/262
        
        static let outlinedWidthOverShapeWidth: CGFloat = 3/108
        static let stripedWidthOverOutlinedWidth: CGFloat = 0.8/2
        static let numberOfStripsOverShapeWidth: CGFloat = 26/108

        static let cornerRadiusOverWidth: CGFloat = 1/20
        
        static let borderWidthOverSqrtArea: CGFloat = 0.04
    }
}

extension CardView.Filling: CustomStringConvertible {
    var description: String {
        switch self {
        case .none: return "Open"
        case .solid: return "Solid"
        case .striped: return "Striped"
        }
    }
}

extension CardView.Shape: CustomStringConvertible {
    var description: String {
        switch self {
        case .diamond: return "Diamond"
        case .oval: return "Oval"
        case .squiggle: return "Squiggle"
        }
    }
}

extension CardView {
    var copiedInstance: CardView {
        let serializedData = NSKeyedArchiver.archivedData(withRootObject: self)
        let deserializedView = NSKeyedUnarchiver.unarchiveObject(with: serializedData) as! CardView
        return deserializedView
    }
    
    private var colorString: String {
        switch color {
        case .green: return "Green"
        case .purple: return "Purple"
        case .red: return "Red"
        default: return "Unsupported color"
        }
    }
    
    override var description: String {
        let numberStr = "\(number)".padding(toLength: "three".count, withPad: " ", startingAt: 0)
        let colorStr = colorString.padding(toLength: "purple".count, withPad: " ", startingAt: 0)
        let fillingStr = "\(fillingKind)".padding(toLength: "striped".count, withPad: " ", startingAt: 0)
        let shapeStr = "\(shape)".padding(toLength: "rectangle".count, withPad: " ", startingAt: 0)
        return "CardView: \(numberStr)  \(colorStr)  \(fillingStr)  \(shapeStr)"
    }
}
