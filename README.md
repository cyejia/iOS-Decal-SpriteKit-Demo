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

We start with the score. It's an SKLabelNode, since we want it to show some string, in this case, our score. The default font size is 32, which is a bit small, so we set it to 40. The we add the node to the tree, with self as the root.

The ground, paddle, and ball are SKShapeNodes, which are pretty simple. Just specify the shape, size, position, and color, then add to self.

The left and right arrows are SKSpriteNodes made with images found in Assets.xcassets. You can drag and drop pictures in there from Finder. We change the anchor to (0, 0) of the Sprite, and then rotate it (which makes it weird for positioning, but you can play around with these values). (We can actually keep the anchor at (0.5, 0.5) and I think that makes it easier but I'm too far into this lol).

## Part 2: Game Interaction

Add SKPhysicsContactDelegate to GameScene's delegates (proofread this).

At the beginning of your didMove(to:), add 
```swift
self.physicsWorld.contactDelegate = self
self.physicsWorld.gravity = CGVector(dx: 0, dy: -2)
```
This will allow you to keep track of contacts between your children, and simulate gravity.

Outside of the class declaration, set up a struct that will keep track of your different objects bit masks, used for contacts and collisions, like so:
```swift
struct PhysicsCategory {
    static let ground : UInt32 = 0x1 << 1
    static let wall : UInt32 = 0x1 << 2
    static let paddle : UInt32 = 0x1 << 3
    static let ball : UInt32 = 0x1 << 4
}
```

For each of nodes that should interact (so in this case, all of them including self, excluding the score SKLabelNode), set up their physicsBody like
```swift
[node].physicsBody = SKPhysicsBody([appropriate parameters for shape])
[node].physicsBody?.categoryBitMask = PhysicsCategory.[appropriate value for this node specified in struct, ex: ground]
[node].physicsBody?.collisionBitMask = Similar to categoryBitMask, but for all the nodes you want to keep track of collisions with. Can do multiple by doing BitMask | BitMask
[node].physicsBody?.contactTestBitMask = Same, but for general contact
[node].physicsBody?.affectedByGravity = [boolean] // self explanatory
[node].physicsBody?.isDynamic = [boolean] // If you want this node to move when hit by other nodes
```
This part is really repetitive, so I'm not going to write all of it out. Here's the code for self, and try to figure the other nodes out.
```swift
self.physicsBody = SKPhysicsBody(edgeLoopFrom : self.frame)
self.physicsBody?.categoryBitMask = PhysicsCategory.wall
self.physicsBody?.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.paddle
self.physicsBody?.contactTestBitMask = PhysicsCategory.ball | PhysicsCategory.paddle
self.physicsBody?.affectedByGravity = false
self.physicsBody?.isDynamic = false
```

TODO:
* touchesBegan, touchesEnded, didBegin(_ contact: SKPhysicsContact)

## Credits
[Arrow icons](https://icons8.com/web-app/10755/Give-Way)
