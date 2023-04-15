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

enum Layers: CGFloat {
    case background = -1.0
    case sprites = 0.0
    case interface = 1.0
}

struct Coordinate {
    var x: Int
    var y: Int

    func toPosition() -> CGPoint {
        return CGPoint(
            x: CGFloat(x),
            y: CGFloat(Screen.size - y)
        )
    }

    func move(direction: Direction, pixels: Int = 2) -> Coordinate {
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
    static let framesPerSecond = 30
    static let movementSpeed = 8.0
    static let origin = Coordinate(x: 0, y: 0)
    static let edge = Coordinate(x: Screen.size - Sprite.size, y: Screen.size - Sprite.size)
    static let size = 128

    func use(scene: SKScene) {
        scene.speed = Screen.movementSpeed
    }

    static func setup(sprite: SKSpriteNode) {
        sprite.anchorPoint = CGPoint(x: 0, y: 1.0)
        sprite.texture?.filteringMode = .nearest
    }

    static func randomCoordinate() -> Coordinate {
        return Coordinate(x: Int.random(in: 0..<Screen.size), y: Int.random(in: 0..<Screen.size))
    }
}

struct Sprite {
    static let size = 8
}

struct SoundPlayer {
    let laser: SKAction

    init() {
        laser = SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false)
    }
}

struct Color {
    static let lightBlue = NSColor(red: 0.16, green: 0.68, blue: 1.00, alpha: 1.00)
    static let darkBlue = NSColor(red: 0.11, green: 0.17, blue: 0.33, alpha: 1.00)
    static let lightGrey = NSColor(red: 0.76, green: 0.76, blue: 0.78, alpha: 1.00)
    static let darkGrey = NSColor(red: 0.37, green: 0.34, blue: 0.31, alpha: 1.00)
    static let black = NSColor(red: 0, green: 0, blue: 0, alpha: 1.00)
    static let white = NSColor(red: 1, green: 1, blue: 1, alpha: 1.00)
}

struct Text {
    private(set) var node: SKNode!
    private var blinkColors = [
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.lightGrey,
        Color.lightGrey,
        Color.white,
        Color.white,
        Color.lightGrey,
        Color.lightGrey
    ]
    private let display = SKLabelNode(fontNamed: "PICO-8")
    var blinkIndex = 0
    var text: String
    var color: NSColor

    init(text: String, color: NSColor, coordinate: Coordinate) {
        self.text = text
        self.color = color
        node = SKNode()
        node.position = coordinate.toPosition()
        node.zPosition = Layers.interface.rawValue
        drawText()
    }

    mutating func blink() {
        blinkIndex = blinkIndex >= blinkColors.count - 1 ? 0 : blinkIndex + 1
        display.fontColor = blinkColors[blinkIndex]
    }

    private func drawText() {
        display.fontSize = 6
        display.fontColor = self.color
        display.text = text
        node.addChild(display)
    }
}
