# iOS-Decal-SpriteKit-Demo
Walkthrough of basic SpriteKit features through building a simple game. 

The finished code at the end of each step is available if you want to start at any part, or if you want to see exactly what was done.

Here's what we're going to be building:

![gif](https://github.com/cyejia/iOS-Decal-SpriteKit-Demo/blob/master/demo.gif)

The actual game will be faster. Idk how to make the gif not so laggy :(

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

Let's add a variable to keep track of our game state.
```swift
var gameOver = false
```

Then add SKPhysicsContactDelegate to GameScene's delegates.

At the beginning of our didMove(to:), add 
```swift
self.physicsWorld.contactDelegate = self
self.physicsWorld.gravity = CGVector(dx: 0, dy: -2)
```
This will allow us to keep track of contacts between nodes, and simulate gravity.

Outside of the class declaration, set up a struct that will keep track of our different objects bit masks, used for contacts and collisions, like so:
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
[node].physicsBody?.collisionBitMask = PhysicsCategory.[mask specified in the struct] // Similar to categoryBitMask, but for all the nodes we want to keep track of collisions with. Can do multiple by doing BitMask | BitMask
[node].physicsBody?.contactTestBitMask = PhysicsCategory.[mask specified in the struct] // Same, but for general contact
[node].physicsBody?.affectedByGravity = [boolean] // self explanatory
[node].physicsBody?.isDynamic = [boolean] // If we want this node to move when hit by other nodes
```
This part is really repetitive, so I'm not going to write all of it out. Here's the code for self, and try to figure the other nodes out.
```swift
self.physicsBody = SKPhysicsBody(edgeLoopFrom : self.frame) // Creates a border around the frame that other nodes can interact with
self.physicsBody?.categoryBitMask = PhysicsCategory.wall
self.physicsBody?.collisionBitMask = PhysicsCategory.ball // We don't want the ball to go off screen
self.physicsBody?.contactTestBitMask = PhysicsCategory.ball
self.physicsBody?.affectedByGravity = false
self.physicsBody?.isDynamic = false // Don't want the frame to move around when hit by the ball
```

Next we're going to set up our user interaction. Since we're working with the simulator, we're just going to focus on touch events. We want the paddle to move left or right while we're pressing the arrows. The function touchesBegan gets called when a touch event happens (i.e. tap, press, swipe), so we're going to override its contents, but we only want to do so if the game is not over.
```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // Called when a touch begins
    if (!gameOver) {
        let touch = touches.first! as UITouch 
        // Since we don't care if the user moves where they touched
        let location = touch.location(in: self) 
        // Check where the user pressed
        if (rightArrow.contains(location)) { 
            // If the user pressed the right arrow
            paddle.run(SKAction.moveBy(x: 1500, y: 0, duration: 10)) 
            // Move the paddle to the right. This line is janky btw, but 
            // it'll do for the demo
        } else if (leftArrow.contains(location)) {
            paddle.run(SKAction.moveBy(x: -1500, y: 0, duration: 10))
        }
    }
}
```

Similarly for touchesEnded, we want the paddle to stop.
```swift
override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    paddle.removeAllActions() 
    // Removes any SKActions paddle currently has. For our game, should only 
    // be one moveBy action at a time
}
```

Finally, we want to handle contact events between our nodes. This is handled in  didBegin(_ contact: SKPhysicsContact). Let's go over our contact events
1. If the ball touches the paddle and the game isn't over, we want it to bounce back up, and we want our score to increment
2. If the ball touches the border and the game isn't over, we want it to bounce away from the border
3. If the ball touches the ground, we want the game to end, and to display a game over label

```swift
func didBegin(_ contact: SKPhysicsContact) {
    if (!self.gameOver) { 
        let firstObject = contact.bodyA // contact keeps track of the two objects that touched
        let secondObject = contact.bodyB
        
        // We don't know which object is bodyA or bodyB, so we have to check 
        // both possibilities for each of our tests. We check using 
        // categoryBitMasks, which we defined earlier in our struct.
        if (firstObject.categoryBitMask == PhysicsCategory.ball && secondObject.categoryBitMask == PhysicsCategory.paddle ||
            secondObject.categoryBitMask == PhysicsCategory.ball && firstObject.categoryBitMask == PhysicsCategory.paddle) {
            // If the ball and paddle touch
            let rand = Int(arc4random_uniform(100)) - 50
            ball.physicsBody?.velocity = CGVector(dx: rand * 2, dy: 500) 
            // Change the velocity of the ball. We're moving it randomly in 
            // the x-direction, but you can add more logic to have it depend
            // on where it touched the paddle, or other things
            score.text = String(Int(score.text!)! + 1) 
            // Increment our score label
        } else if (firstObject.categoryBitMask == PhysicsCategory.wall && secondObject.categoryBitMask == PhysicsCategory.ball || secondObject.categoryBitMask == PhysicsCategory.wall && firstObject.categoryBitMask == PhysicsCategory.ball) {
            // If the ball hits a wall
            ball.physicsBody?.velocity = CGVector(dx: -1 * (ball.physicsBody?.velocity.dx)!, dy: (ball.physicsBody?.velocity.dy)!)
            // Reflect the ball off the wall in the x-direction, keep its
            // velocity in the y-direction
        } else if (firstObject.categoryBitMask == PhysicsCategory.ground && secondObject.categoryBitMask == PhysicsCategory.ball || secondObject.categoryBitMask == PhysicsCategory.ground && firstObject.categoryBitMask == PhysicsCategory.ball) {
            // If the ball hits the ground
            ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            // Stop the ball
            let gameOver = SKLabelNode(text: "Game Over")
            gameOver.fontSize = 72
            gameOver.fontColor = UIColor.red
            gameOver.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
            self.addChild(gameOver)
            // Create a gameOver SKLabelNode, display it
            self.gameOver = true
            // Set our class variable gameOver to true
        }
    }
}
```

And we're done! There's a lot of ways to expand this game, and have it not be as janky, but this should give you a foundation for most basic games :) 

## Some Stuff We Didn't Cover
* We haven't implemented restarting the game (right now you can't interact with the game after you lose), but basically you would just need to reset the positions of your nodes, and remove the gameOver SKLabelNode. 
* We didn't cover how to use accelerometer data since not everyone in the class has an iPhone, and it won't work on the simulator. 
* We'll learn more about persistently storing data later in the class, so I won't cover that in this demo.

## Credits
[Arrow icons](https://icons8.com/web-app/10755/Give-Way)
