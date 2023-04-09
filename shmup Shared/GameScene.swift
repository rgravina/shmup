import SpriteKit

enum Direction {
    case none, left, right, down, up
}

enum KeyCodes: UInt16 {
    case zKey = 6
    case xKey = 7
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
        default:
            return .none
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

    func move(direction: Direction, pixels: Int = 1) -> Coordinate {
        switch direction {
        case .left:
            return left(pixels: pixels)
        case .right:
            return right(pixels: pixels)
        case .down:
            return down(pixels: pixels)
        case .up:
            return up(pixels: pixels)
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

    private func left(pixels: Int) -> Coordinate { Coordinate(x: x - pixels, y: y) }
    private func right(pixels: Int) -> Coordinate { Coordinate(x: x + pixels, y: y) }
    private func down(pixels: Int) -> Coordinate { Coordinate(x: x, y: y + pixels) }
    private func up(pixels: Int) -> Coordinate { Coordinate(x: x, y: y - pixels) }
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
    private var fire: SKSpriteNode?
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
        if let fire = fire {
            let coordinate = Coordinate.from(position: fire.position)
            let newCoordinate = coordinate.move(direction: .up, pixels: 2)
            if newCoordinate.y > Screen.origin.y {
                fire.position = newCoordinate.toPosition()
            } else {
                fire.removeFromParent()
            }
        }
    }

    override func keyUp(with event: NSEvent) {
        let keyCode = KeyCodes(rawValue: event.keyCode)
        if keyCode?.toDirection() == currentDirection {
            currentDirection = .none
        }
    }

    override func keyDown(with event: NSEvent) {
        let keyCode = KeyCodes(rawValue: event.keyCode)
        let direction = keyCode?.toDirection() ?? Direction.none
        if direction != .none {
            currentDirection = direction
        }
        if keyCode == KeyCodes.zKey {
            fire?.removeFromParent()
            fire = screen.display(imageNamed: "fire")
            fire!.position = currentCoordinate.move(direction: .up, pixels: Sprite.size).toPosition()
        }
    }
}
