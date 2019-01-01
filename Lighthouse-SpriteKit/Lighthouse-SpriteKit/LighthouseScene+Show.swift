//
//  LighthouseScene+Show.swift
//  Lighthouse-SpriteKit
//
//  Created by Andrew Finke on 12/21/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import SpriteKit

extension LighthouseScene {
    
    func createLighthouses() {
        let xCount = Int(size.width / (Design.lighthouseSize + Design.lighthouseSpacing))
        let yCount = Int(size.height / (Design.lighthouseSize + Design.lighthouseSpacing))
        
        let target = SKShapeNode(circleOfRadius: Design.lighthouseSize / 2)
        target.fillColor = .white
        let texture = SKView().texture(from:target)!
        
        if lighthouses.isEmpty {
            for row in 0..<yCount {
                lighthouses.append([])
                for _ in 0..<xCount {
                    let lighthouse = Lighthouse(texture: texture)
                    lighthouse.queue = actionQueue
                    lighthouse.alpha = 0.0
                    addChild(lighthouse)
                    lighthouses[row].append(lighthouse)
                }
            }
        }
        
        let xSpacing = size.width / CGFloat(xCount)
        let ySpacing = size.height / CGFloat(yCount)
        let centerOffset = Design.lighthouseSpacing / 2
        for y in 0..<yCount {
            let yPosition = ySpacing * CGFloat(y) + centerOffset
            for x in 0..<xCount {
                let lighthouse = lighthouses[y][x]
                lighthouse.position = CGPoint(x: xSpacing * CGFloat(x) + centerOffset,
                                              y: yPosition)
            }
        }
    }

    func lighthousesIndexRange(around location: CGPoint, range: Int) -> (x: Range<Int>, y: Range<Int>, centerPosition: CGPoint) {
        let xCount = Int(size.width / (Design.lighthouseSize + Design.lighthouseSpacing))
        let yCount = Int(size.height / (Design.lighthouseSize + Design.lighthouseSpacing))
        let xCenter = Int(CGFloat(xCount) * location.x / size.width)
        let yCenter = Int(CGFloat(yCount) * location.y / size.height)
        
        let xIndexLow = max(0, xCenter - range / 2)
        let xIndexHigh = min(xCenter + range / 2 + 1, xCount)
        let yIndexLow = max(0, yCenter - range / 2)
        let yIndexHigh = min(yCenter + range / 2 + 1, yCount)
        
        return (xIndexLow..<xIndexHigh, yIndexLow..<yIndexHigh, lighthouses[yCenter][xCenter].position)
    }
    
    func lighthousesIndexRangeToRadius(x: Range<Int>, y: Range<Int>) -> CGFloat {
        let lighthouseCount = max(x.upperBound - x.lowerBound, y.upperBound - y.lowerBound)
        let distance = CGFloat(lighthouseCount) * (Design.lighthouseSize + Design.lighthouseSpacing)
        return distance / 2
    }
    
    func addExplosion(around location: CGPoint, range: Int = 8) {
        var nearbyLighthouses = [Lighthouse]()
        let lighthousesIndexRange = self.lighthousesIndexRange(around: location, range: range)
        
        for y in lighthousesIndexRange.y {
            for x in lighthousesIndexRange.x {
                let lighthouse = lighthouses[y][x]
                nearbyLighthouses.append(lighthouse)
            }
        }
        
        let center = lighthousesIndexRange.centerPosition
        let radius = lighthousesIndexRangeToRadius(x: lighthousesIndexRange.x, y: lighthousesIndexRange.y)
        
        for lh in nearbyLighthouses {
            let dist = sqrt(pow(lh.position.x - center.x, 2) + pow(lh.position.y - center.y, 2))
            if dist > radius { continue }
            lh.queue(action: self.action, delay: Double(dist / 200))
        }
    }
}
