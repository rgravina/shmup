import SpriteKit

enum Direction {
    case none, left, right, down, up
}

enum KeyCodes: UInt16 {
    case leftArrow = 123
    case rightArrow = 124
    case downArrow = 125
    case upArrow = 126

    func toDirection() -> Direction {
        switch self {
        case KeyCodes.leftArrow:
            return .left
        case KeyCodes.rightArrow:
            return .right
        case KeyCodes.downArrow:
            return .down
        case KeyCodes.upArrow:
            return .up
        }
    }
}

struct Coordinate {
    var x: Int
    var y: Int

    static func from(position: CGPoint) -> Coordinate {
        return Coordinate(
            x: Int(position.x/Screen.scale) + Screen.halfScreenSize,
            y: Int(-position.y/Screen.scale) + Screen.halfScreenSize
        )
    }

    func toPosition() -> CGPoint {
        return CGPoint(
            x: CGFloat(x - Screen.halfScreenSize) * Screen.scale,
            y: CGFloat(-y + Screen.halfScreenSize) * Screen.scale
        )
    }

    func move(direction: Direction) -> Coordinate {
        switch direction {
        case .left:
            return left()
        case .right:
            return right()
        case .down:
            return down()
        case .up:
            return up()
        case .none:
            return self
        }
    }

    func wrapIfNeeded() -> Coordinate {
        if x < Screen.origin.x {
            return moveXEnd()
        }
        if x > Screen.edge.x {
            return moveXStart()
        }
        if y < Screen.origin.y {
            return moveYEnd()
        }
        if y > Screen.edge.y {
            return moveYStart()
        }
        return self
    }

    private func left() -> Coordinate { Coordinate(x: x - 1, y: y) }
    private func right() -> Coordinate { Coordinate(x: x + 1, y: y) }
    private func down() -> Coordinate { Coordinate(x: x, y: y + 1) }
    private func up() -> Coordinate { Coordinate(x: x, y: y - 1) }
    private func moveXStart() -> Coordinate { Coordinate(x: Screen.origin.x, y: y) }
    private func moveXEnd() -> Coordinate { Coordinate(x: Screen.edge.x, y: y) }
    private func moveYStart() -> Coordinate { Coordinate(x: x, y: Screen.origin.y) }
    private func moveYEnd() -> Coordinate { Coordinate(x: x, y: Screen.edge.y) }
}

class Screen {
    static let movementSpeed = 8.0
    static let origin = Coordinate(x: 0, y: 0)
    static let size = 128
    static let halfScreenSize = size/2
    static let scale = 8.0
    static let edge = Coordinate(x: Screen.size - Sprite.size, y: Screen.size - Sprite.size)
    private var scene: SKScene!

    func use(scene: SKScene) {
        scene.speed = Screen.movementSpeed
        self.scene = scene
    }

    func display(imageNamed: String) -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: imageNamed)
        sprite.anchorPoint = CGPoint(x: 0, y: 1.0)
        sprite.setScale(Screen.scale)
        sprite.texture?.filteringMode = .nearest
        scene.addChild(sprite)
        return sprite
    }
}

struct Sprite {
    static let size = 8
}

class GameScene: SKScene {
    private var currentDirection: Direction = .none
    private var currentCoordinate: Coordinate = Coordinate(x: Screen.halfScreenSize, y: Screen.halfScreenSize)
    private var ship: SKSpriteNode!
    private var screen: Screen = Screen()

    class func newGameScene() -> GameScene {
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }

        scene.scaleMode = .aspectFill
        scene.screen.use(scene: scene)
        return scene
    }

    func setUpScene() {
        ship = screen.display(imageNamed: "ship")
    }

    override func didMove(to view: SKView) {
        self.setUpScene()
    }

    override func update(_ currentTime: TimeInterval) {
        currentCoordinate = currentCoordinate
            .move(direction: currentDirection)
            .wrapIfNeeded()
        ship.position = currentCoordinate.toPosition()
    }

    override func keyUp(with event: NSEvent) {
        let keyCode = KeyCodes(rawValue: event.keyCode)
        if keyCode?.toDirection() == currentDirection {
            currentDirection = .none
        }
    }

    override func keyDown(with event: NSEvent) {
        let keyCode = KeyCodes(rawValue: event.keyCode)
        currentDirection = keyCode?.toDirection() ?? Direction.none
    }
}
