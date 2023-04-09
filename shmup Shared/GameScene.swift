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

struct Coordinate {
    var x: Int
    var y: Int
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
        sprite.anchorPoint = CGPoint(x: 0, y: 1.0)
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

        let cooordinate = coords(position: ship.position)
        if (cooordinate.x < 0) {
            ship.position = position(coordinate: Coordinate(x: 120, y: cooordinate.y))
        }
        if (cooordinate.x > 120) {
            ship.position = position(coordinate: Coordinate(x: 0, y: cooordinate.y))
        }
        if (cooordinate.y < 0) {
            ship.position = position(coordinate: Coordinate(x: cooordinate.x, y: 120))
        }
        if (cooordinate.y > 120) {
            ship.position = position(coordinate: Coordinate(x: cooordinate.x, y: 0))
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

    private func coords(position: CGPoint) -> Coordinate {
        return Coordinate(x: Int(position.x/speed) + 64, y: Int(position.y * -1/speed) + 64)
    }

    private func position(coordinate: Coordinate) -> CGPoint {
        return CGPoint(
            x: (CGFloat(coordinate.x) - 64) * speed,
            y: (CGFloat(coordinate.y * -1) + 64) * speed
        )
    }
}
