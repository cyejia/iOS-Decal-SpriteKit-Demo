//
//  GameScene.swift
//  SpriteKit Demo
//
//  Created by Yejia Chen on 10/5/16.
//  Copyright © 2016 iOS Decal. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    /* ----------------
        GAME VARIABLES
       ---------------- */

    var score = SKLabelNode()
    var ground = SKShapeNode()
    var rightArrow = SKSpriteNode()
    var leftArrow = SKSpriteNode()
    var paddle = SKShapeNode()
    var ball = SKShapeNode()
    
    
    override func didMove(to view: SKView) {
        // Set up your scene here
        
        self.backgroundColor = UIColor.white
        
        score = SKLabelNode(text: "0")
        score.fontColor = SKColor.black
        score.fontSize = 40
        score.position =
            CGPoint(x: 25, y: self.frame.height - 50)
        self.addChild(score)
        
        ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.width, height: 75))
        ground.fillColor = UIColor.black
        self.addChild(ground)
        
        rightArrow = SKSpriteNode(imageNamed: "Arrow")
        rightArrow.anchorPoint = CGPoint(x: 0, y: 0)
        rightArrow.size = CGSize(width: 50, height: 50)
        rightArrow.position = CGPoint(x: self.frame.width - 20, y: 12)
        rightArrow.run(SKAction.rotate(byAngle: CGFloat(M_PI_2), duration: 0))
        self.addChild(rightArrow)
        
        leftArrow = SKSpriteNode(imageNamed: "Arrow")
        leftArrow.anchorPoint = CGPoint(x: 0, y: 0)
        leftArrow.size = CGSize(width: 50, height: 50)
        leftArrow.position = CGPoint(x: 20, y: 62)
        leftArrow.run(SKAction.rotate(byAngle: CGFloat(-M_PI_2), duration: 0))
        self.addChild(leftArrow)
        
        paddle = SKShapeNode(rect: CGRect(x: self.frame.width/2 - 50, y: 90, width: 100, height: 20))
        paddle.fillColor = UIColor.blue
        self.addChild(paddle)
        
        ball = SKShapeNode(circleOfRadius: 25)
        ball.position = CGPoint(x: self.frame.width/2, y: self.frame.height - 50)
        ball.fillColor = UIColor.red
        self.addChild(ball)
    }
}
