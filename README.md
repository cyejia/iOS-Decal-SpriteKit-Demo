# iOS-Decal-SpriteKit-Demo
Walkthrough of basic SpriteKit features through building a simple game. 

The finished code at the end of each step is available if you want to start at any part, or if you want to see exactly what was done.

## Part 0: Setup
Create a new Xcode project. Select Game under Application. For Game Technology, choose SpriteKit. In GameScene.swift, delete everything within the class, and in GameScene.sks, delete helloLabel. 

In GameViewController.swift, add 
```swift
scene.size = view.bounds.size
scene.anchorPoint = CGPoint(x:0, y:0)
```
under 
```swift
scene.scaleMode = .aspectFill
```

The first line sets the scene's size to be the screen size. The second line sets the anchorPoint to the bottom-left corner. By default it's (0.5, 0.5), which is the center of the screen. Setting it to the bottom-left corner makes positioning things make more sense later.

## Part 1: Laying out Nodes
First, let's set up our variables. In GameScene.swift, create the following nodes.
```swift
var scoreLabel = SKLabelNode()
var ground = SKShapeNode()
var rightArrow = SKSpriteNode()
var leftArrow = SKSpriteNode()
var basket = SKSpriteNode()
var ball = SKSpriteNode()
```
Next, we want to override the didMove(to view: SKView) function (which we deleted earlier), and set up our nodes.
```swift
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = UIColor.white
                
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontColor = SKColor.black
        scoreLabel.fontSize = 40
        scoreLabel.position =
            CGPoint(x: 25, y: self.frame.height - 50)
        self.addChild(scoreLabel)
        
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
```

Let's go over each part. First, we set the background color of our frame to white, since it's a gray-ish color by default. Then we started adding our nodes.

We start with the score. It's an SKLabelNode, since we want it to show some string, in this case, our score. The default font size is 32, which is a bit small, so we set it to 40.


## Credits
[Arrow icons](https://icons8.com/web-app/10755/Give-Way)
