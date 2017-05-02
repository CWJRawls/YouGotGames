//
//  GameViewController.swift
//  You Got Games
//
//  Created by synthesis on 4/19/17.
//  Copyright © 2017 Connor Rawls. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class GameViewController : UIViewController {
    
    var sceneType : SceneType = SceneType.waiting //variable for which type of scene should be shown to the player
    var scene : SKScene? //scene that will dominate the frame, either history / judging / playing / waiting / winning

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}

enum SceneType {
    case history //for when we need to show the player what the last judge did
    case judging //for having the judge choose
    case playing //for everyone not the judge selecting cards to play
    case waiting //for everyone not the current player waiting their turn
    case winning //for everyone when a player has reached the maximum number of wins
}
