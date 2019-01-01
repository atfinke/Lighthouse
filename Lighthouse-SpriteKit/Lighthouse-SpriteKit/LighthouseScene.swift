//
//  GameScene.swift
//  Lighthouse-SpriteKit
//
//  Created by Andrew Finke on 12/13/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Design {
    static let lighthouseSize: CGFloat = 7.5
    static let lighthouseSpacing: CGFloat = 30.0
}

class LighthouseScene: SKScene {
    
    var lighthouses = [[Lighthouse]]()
    let actionQueue = DispatchQueue(label: "com.andrewfinke.actions")
    
    let action: SKAction = {
        return SKAction.sequence([
            SKAction.group([
                .fadeAlpha(to: 1.0, duration: 1.0),
                .colorize(with: .white, colorBlendFactor: 1, duration: 0.2),
                .scale(to: 1.4, duration: 1.0)
                ]),
            SKAction.group([
                .fadeAlpha(to: 0.0, duration: 1.0),
                .scale(to: 1.0, duration: 1.0)
                ])
            ])
    }()
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        anchorPoint = CGPoint(x: 0, y: 0)
        
        createLighthouses()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { fatalError() }
        addExplosion(around: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { fatalError() }
        addExplosion(around: location)
    }
}
