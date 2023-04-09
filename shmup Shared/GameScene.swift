import SpriteKit

enum Direction {
    case none, left, right, down, up
}

enum KeyCodes: UInt16 {
    case left = 123
    case right = 124
    case down = 125
    case up = 126
}

class GameScene: SKScene {
    private let movementSpeed = 8.0
    private let spriteScale = 8.0
    private var currentDirection: Direction = .none
    private var ship: SKSpriteNode!

    class func newGameScene() -> GameScene {
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        speed = movementSpeed
        ship = displaySprite(imageNamed: "ship")
    }

    private func displaySprite(imageNamed: String) -> SKSpriteNode  {
        let sprite = SKSpriteNode(imageNamed: imageNamed)
        sprite.setScale(spriteScale)
        sprite.texture?.filteringMode = .nearest
        addChild(sprite)
        return sprite
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }

    override func update(_ currentTime: TimeInterval) {
        switch(currentDirection) {
        case .left:
            ship.position = CGPoint(
                x: ship.position.x - speed,
                y: ship.position.y
            )
        case .right:
            ship.position = CGPoint(
                x: ship.position.x + speed,
                y: ship.position.y
            )
        case .down:
            ship.position = CGPoint(
                x: ship.position.x,
                y: ship.position.y - speed
            )
        case .up:
           ship.position = CGPoint(
               x: ship.position.x,
               y: ship.position.y + speed
           )
        case .none:
            break
        }
    }


    override func keyUp(with event: NSEvent) {
        if (keyCodeToDirection(keyCode: event.keyCode) == currentDirection) {
            currentDirection = .none
        }
    }

    override func keyDown(with event: NSEvent) {
        currentDirection = keyCodeToDirection(keyCode: event.keyCode)
    }

    private func keyCodeToDirection(keyCode: UInt16) -> Direction  {
        switch(keyCode) {
        case KeyCodes.left.rawValue:
            return .left
        case KeyCodes.right.rawValue:
            return .right
        case KeyCodes.down.rawValue:
            return .down
        case KeyCodes.up.rawValue:
            return .up
        default:
            return .none
        }
    }
}
