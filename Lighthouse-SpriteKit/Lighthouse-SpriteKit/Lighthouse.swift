//
//  Lighthouse.swift
//  Lighthouse-SpriteKit
//
//  Created by Andrew Finke on 12/13/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import SpriteKit

class Lighthouse: SKSpriteNode {
    var queue: DispatchQueue?
    
    func queue(action: SKAction, delay: Double) {
        queue?.asyncAfter(deadline: DispatchTime.now() + delay) {
            self.removeAllActions()
            self.run(action)
        }
    }
}
