//
//  GameScene.swift
//  SpriteKit Demo
//
//  Created by Yejia Chen on 10/5/16.
//  Copyright © 2016 iOS Decal. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let ground : UInt32 = 0x1 << 1
    static let wall : UInt32 = 0x1 << 2
    static let paddle : UInt32 = 0x1 << 3
    static let ball : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var score = SKLabelNode()
    var ground = SKShapeNode()
    var rightArrow = SKSpriteNode()
    var leftArrow = SKSpriteNode()
    var paddle = SKSpriteNode()
    var ball = SKShapeNode()
    var gameOver = false
    
    
    override func didMove(to view: SKView) {
        // Set up your scene here
        
        self.backgroundColor = UIColor.white
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -2)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom : self.frame)
        self.physicsBody?.categoryBitMask = PhysicsCategory.wall
        self.physicsBody?.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.paddle
        self.physicsBody?.contactTestBitMask = PhysicsCategory.ball | PhysicsCategory.paddle
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = false
        
        score = SKLabelNode(text: "0")
        score.fontColor = SKColor.black
        score.fontSize = 40
        score.position =
            CGPoint(x: 25, y: self.frame.height - 50)
        self.addChild(score)
        
        ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.width, height: 75))
        ground.fillColor = UIColor.black
        ground.physicsBody = SKPhysicsBody(edgeLoopFrom: ground.frame)
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.ball
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
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
        
        
        paddle = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 100, height: 20))
        paddle.position = CGPoint(x: self.frame.width/2, y: 90)
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.categoryBitMask = PhysicsCategory.paddle
        paddle.physicsBody?.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.wall
        paddle.physicsBody?.contactTestBitMask = PhysicsCategory.ball | PhysicsCategory.wall
        paddle.physicsBody?.affectedByGravity = false
        paddle.physicsBody?.isDynamic = false

        self.addChild(paddle)
        
        ball = SKShapeNode(circleOfRadius: 25)
        ball.position = CGPoint(x: self.frame.width/2, y: self.frame.height - 50)
        ball.fillColor = UIColor.red
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody?.collisionBitMask = PhysicsCategory.paddle | PhysicsCategory.wall | PhysicsCategory.ground
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.paddle | PhysicsCategory.wall | PhysicsCategory.ground
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.isDynamic = true

        self.addChild(ball)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Called when a touch begins
        if (!gameOver) {
            let touch = touches.first! as UITouch
            let location = touch.location(in: self)
            if (rightArrow.contains(location)) {
                paddle.run(SKAction.moveBy(x: 1500, y: 0, duration: 10))
            } else if (leftArrow.contains(location)) {
                paddle.run(SKAction.moveBy(x: -1500, y: 0, duration: 10))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        paddle.removeAllActions()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (!self.gameOver) {
            let firstObject = contact.bodyA
            let secondObject = contact.bodyB
            
            if (firstObject.categoryBitMask == PhysicsCategory.ball && secondObject.categoryBitMask == PhysicsCategory.paddle ||
                secondObject.categoryBitMask == PhysicsCategory.ball && firstObject.categoryBitMask == PhysicsCategory.paddle) {
                let rand = Int(arc4random_uniform(100)) - 50
                ball.physicsBody?.velocity = CGVector(dx: rand * 2, dy: 500)
                score.text = String(Int(score.text!)! + 1)
            } else if (firstObject.categoryBitMask == PhysicsCategory.wall && secondObject.categoryBitMask == PhysicsCategory.ball || secondObject.categoryBitMask == PhysicsCategory.wall && firstObject.categoryBitMask == PhysicsCategory.ball) {
                ball.physicsBody?.velocity = CGVector(dx: -1 * (ball.physicsBody?.velocity.dx)!, dy: (ball.physicsBody?.velocity.dy)!)
            } else if (firstObject.categoryBitMask == PhysicsCategory.ground && secondObject.categoryBitMask == PhysicsCategory.ball || secondObject.categoryBitMask == PhysicsCategory.ground && firstObject.categoryBitMask == PhysicsCategory.ball) {
                ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                let gameOver = SKLabelNode(text: "Game Over")
                gameOver.fontSize = 72
                gameOver.fontColor = UIColor.red
                gameOver.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
                self.addChild(gameOver)
                self.gameOver = true
            }
        }
    }
}
