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

    func moveToSpriteCenter() -> Coordinate {
        return Coordinate(x: x + Sprite.size/2, y: y + Sprite.size/2)
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

    func contain() -> Coordinate {
        if x < Screen.origin.x {
            return moveXStart()
        }
        if x > Screen.edge.x {
            return moveXEnd()
        }
        if y < Screen.origin.y {
            return moveYStart()
        }
        if y > Screen.edge.y {
            return moveYEnd()
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

    static func randomStartingCoordinate() -> Coordinate {
        return Coordinate(x: Int.random(in: 0..<(Screen.size - Sprite.size)), y: -Sprite.size)
    }
}

struct Sprite {
    static let size = 8
}

protocol Drawable {
    func add(parent: SKNode)
    func remove()
}

protocol Pixelatable {
    func pixelate(using view: SKView)
}

class SpriteSheet {
    let texture: SKTexture
    let spriteWidth: CGFloat
    let spriteHeight: CGFloat
    let rows: Int
    let cols: Int

    init(imageNamed: String, rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        texture = SKTexture(imageNamed: imageNamed)
        texture.filteringMode = .nearest
        let width = texture.textureRect().width
        let height = texture.textureRect().height
        spriteWidth = width/CGFloat(cols)
        spriteHeight = height/CGFloat(rows)
    }

    func sprite(row: Int, col: Int, cells: Int = 1) -> SKSpriteNode {
        let sprite = SKSpriteNode(texture: texture(row: row, col: col, cells: cells))
        sprite.anchorPoint = .init(x: 0, y: 0)
        return sprite
    }

    func texture(row: Int, col: Int, cells: Int = 1) -> SKTexture {
        return SKTexture(
            rect: CGRect(
                x: spriteWidth * CGFloat(col),
                y: spriteHeight * CGFloat(rows - row - 1 * cells),
                width: spriteWidth * CGFloat(cells),
                height: spriteHeight * CGFloat(cells)
            ),
            in: texture
        )
    }
}

struct SoundPlayer {
    let laser: SKAction
    let collision: SKAction
    let enemyHit: SKAction
    let enemyDestroy: SKAction

    init() {
        laser = SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false)
        collision = SKAction.playSoundFileNamed("collision.wav", waitForCompletion: false)
        enemyHit = SKAction.playSoundFileNamed("enemyhit.wav", waitForCompletion: false)
        enemyDestroy = SKAction.playSoundFileNamed("enemydestroy.wav", waitForCompletion: false)
    }
}

struct Color {
    static let black = NSColor(red: 0, green: 0, blue: 0, alpha: 1)
    static let darkBlue = NSColor(red: 0.11, green: 0.17, blue: 0.33, alpha: 1)
    static let purple = NSColor(red: 0.49, green: 0.15, blue: 0.33, alpha: 1)
    static let darkGreen = NSColor(red: 0, green: 0.53, blue: 0.32, alpha: 1)
    static let darkBrown = NSColor(red: 0.67, green: 0.32, blue: 0.21, alpha: 1)
    static let darkGrey = NSColor(red: 0.37, green: 0.34, blue: 0.31, alpha: 1)
    static let lightGrey = NSColor(red: 0.76, green: 0.76, blue: 0.78, alpha: 1)
    static let white = NSColor(red: 1, green: 0.95, blue: 0.91, alpha: 1)
    static let red = NSColor(red: 1, green: 0, blue: 0.30, alpha: 1)
    static let orange = NSColor(red: 1, green: 0.64, blue: 0, alpha: 1)
    static let yellow = NSColor(red: 1, green: 0.93, blue: 0.15, alpha: 1)
    static let lightGreen = NSColor(red: 0, green: 0.89, blue: 0.21, alpha: 1)
    static let lightBlue = NSColor(red: 0.16, green: 0.68, blue: 1, alpha: 1)
    static let mediumGrey = NSColor(red: 0.51, green: 0.46, blue: 0.61, alpha: 1)
    static let pink = NSColor(red: 1, green: 0.47, blue: 0.66, alpha: 1)
    static let lightBrown = NSColor(red: 1, green: 0.80, blue: 0.67, alpha: 1)
}

class Text: Drawable, Pixelatable {
    private var node: SKNode!
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
    private var sprite: SKSpriteNode?
    private var view: SKView?
    var blinkIndex = 0
    var text: String {
        get {
            return display.text ?? ""
        }
        set {
            display.text = newValue
            if let view = view {
                pixelate(using: view)
            }
        }
    }
    var color: NSColor

    init(text: String, color: NSColor, coordinate: Coordinate) {
        self.color = color
        node = SKNode()
        node.position = coordinate.toPosition()
        node.zPosition = Layers.interface.rawValue
        display.text = text
        display.fontSize = 6
        display.fontColor = self.color
        display.text = text
        node.addChild(display)
    }

    func add(parent: SKNode) {
        parent.addChild(node)
    }

    func remove() {
        node.removeFromParent()
    }

    func pixelate(using view: SKView) {
        self.view = view
        sprite?.removeFromParent()
        sprite = SKSpriteNode(texture: view.texture(from: display))
        sprite!.texture?.filteringMode = .nearest
        sprite!.position = display.position
        display.removeFromParent()
        node.addChild(sprite!)
    }

    func blink() {
        blinkIndex = blinkIndex >= blinkColors.count - 1 ? 0 : blinkIndex + 1
        display.fontColor = blinkColors[blinkIndex]
        if let view = view {
            pixelate(using: view)
        }
    }
}
