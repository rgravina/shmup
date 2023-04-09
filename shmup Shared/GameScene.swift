import SpriteKit

enum Direction {
    case none, left, right, up, down
}

enum KeyCodes: UInt16 {
    case left = 123
    case right = 124
    case down = 125
    case up = 126
}

class GameScene: SKScene {
    private var currentDirection: Direction = .none

    class func newGameScene() -> GameScene {
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        displaySprite(imageNamed: "ship")
    }

    private func displaySprite(imageNamed: String) {
        let sprite = SKSpriteNode(imageNamed: imageNamed)
        sprite.setScale(8)
        sprite.texture?.filteringMode = .nearest
        addChild(sprite)
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }

    override func update(_ currentTime: TimeInterval) {
    }


    override func keyUp(with event: NSEvent) {
        currentDirection = .none
    }

    override func keyDown(with event: NSEvent) {
        switch(event.keyCode) {
        case KeyCodes.left.rawValue:
            currentDirection = .left
        case KeyCodes.right.rawValue:
            currentDirection = .right
        case KeyCodes.down.rawValue:
            currentDirection = .down
        case KeyCodes.up.rawValue:
            currentDirection = .up
        default:
            currentDirection = .none
        }
    }
}
