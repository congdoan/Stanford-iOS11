//
//  Array+Ext.swift
//  SetGame
//
//  Created by Cong Doan on 8/16/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

extension Array {
    
    mutating func shuffle() {
        guard count > 1 else {
            return
        }
        
        for index in 1..<count {
            let randomIndex = (index + 1).arc4random
            let temp = self[index]
            self[index] = self[randomIndex]
            self[randomIndex] = temp
        }
    }
    
    @discardableResult
    mutating func remove(positions: [Int], _ positionsSorted: Bool = false) -> [Element] {
        let removedElements = positions.map { self[$0] }
        moveToLast(positions: positions, positionsSorted)
        removeLast(positions.count)
        return removedElements
    }
    
    mutating func moveToLast(positions: [Int], _ positionsSorted: Bool = false) {
        guard let minPos = positionsSorted ? positions.first : positions.min() else { return }
        let idxSet = Set(positions)
        var pos = minPos
        for idx in minPos+1..<count {
            if !idxSet.contains(idx) {
                swapAt(idx, pos)
                pos += 1
            }
        }
    }
    
}
