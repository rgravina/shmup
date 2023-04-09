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

    static func from(position: CGPoint) -> Coordinate {
        return Coordinate(x: Int(position.x/Screen.scale) + 64, y: Int(position.y * -1/Screen.scale) + 64)
    }

    func toPosition() -> CGPoint {
        return CGPoint(
            x: (CGFloat(x) - 64) * Screen.scale,
            y: (CGFloat(y * -1) + 64) * Screen.scale
        )
    }
}

struct Screen {
    static var movementSpeed = 8.0
    static var origin = Coordinate(x: 0, y: 0)
    static var size = 128
    static var scale = 8.0
}

struct Sprite {
    static var size = 8
}

class GameScene: SKScene {
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
        speed = Screen.movementSpeed
        ship = displaySprite(imageNamed: "ship")
    }

    private func displaySprite(imageNamed: String) -> SKSpriteNode  {
        let sprite = SKSpriteNode(imageNamed: imageNamed)
        sprite.anchorPoint = CGPoint(x: 0, y: 1.0)
        sprite.setScale(Screen.scale)
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

        let cooordinate = Coordinate.from(position: ship.position)
        let edge = Screen.size - Sprite.size
        if (cooordinate.x < Screen.origin.x) {
            ship.position = Coordinate(x: edge, y: cooordinate.y).toPosition()
        }
        if (cooordinate.x > edge) {
            ship.position = Coordinate(x: Screen.origin.x, y: cooordinate.y).toPosition()
        }
        if (cooordinate.y < Screen.origin.y) {
            ship.position = Coordinate(x: cooordinate.x, y: edge).toPosition()
        }
        if (cooordinate.y > edge) {
            ship.position = Coordinate(x: cooordinate.x, y: Screen.origin.y).toPosition()
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
