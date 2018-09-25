//
//  Card.swift
//  SetGame
//
//  Created by Cong Doan on 8/16/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

struct Card: Equatable, CustomStringConvertible {
    
    enum Number: Int {
        case one = 1
        case two
        case three
    }
    
    static let allNumbers = [Number.one, .two, .three]
    
    enum Shape {
        case diamond, oval, squiggle
    }
    
    static let allShapes = [Shape.diamond, .oval, .squiggle]
    
    enum Shading {
        case solid, striped, outlined
    }
    
    static let allShadings = [Shading.solid, .striped, .outlined]
    
    enum Color {
        case red, green, purple
        
        var uiColor: UIColor {
            switch self {
            case .red:
                return UIColor.red
            case .green:
                return UIColor.green
            case .purple:
                return UIColor.purple
            }
        }
    }
    
    static let allColors = [Color.red, .green, .purple]
    
    let number: Number
    let shape: Shape
    let shading: Shading
    let color: Color
    
    var description: String {
        let numberStr = "\(number)".padding(toLength: "three".count, withPad: " ", startingAt: 0)
        let colorStr = "\(color)".padding(toLength: "purple".count, withPad: " ", startingAt: 0)
        let shadingStr = "\(shading)".padding(toLength: "striped".count, withPad: " ", startingAt: 0)
        let shapeStr = "\(shape)".padding(toLength: "rectangle".count, withPad: " ", startingAt: 0)
        return "\(numberStr)  \(colorStr)  \(shadingStr)  \(shapeStr)"
    }
    
}
