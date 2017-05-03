//
//  WaitingScene.swift
//  You Got Games
//
//  Created by Connor Rawls on 5/2/17.
//  Copyright © 2017 Connor Rawls. All rights reserved.
//

import Foundation
import SpriteKit

class WaitingScene : SKScene {
    
    var background = SKSpriteNode(imageNamed: "green_felt_back")
    
    override func didMove(to view: SKView) {
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addChild(background)
    }
    
}
