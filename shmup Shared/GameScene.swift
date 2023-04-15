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

struct Lives {
    private(set) var coordinate: Coordinate = Coordinate(x: 2, y: 2)
    private(set) var node: SKNode!
    static let total = 4
    let lives = 1

    init() {
        node = SKNode()
        node.position = coordinate.toPosition()
        drawLives()
    }

    private func drawLives() {
        for index in 0..<Lives.total {
            let lifeAvailable = SKSpriteNode(imageNamed: "life_0")
            lifeAvailable.zPosition = Layers.interface.rawValue
            let lifeUnavailable = SKSpriteNode(imageNamed: "life_1")
            lifeUnavailable.zPosition = Layers.interface.rawValue
            if index < lives {
                Screen.setup(sprite: lifeAvailable)
                lifeAvailable.position = CGPoint(x: index * (Sprite.size + 1), y: 0)
                node.addChild(lifeAvailable)
            } else {
                Screen.setup(sprite: lifeUnavailable)
                lifeUnavailable.position = CGPoint(x: index * (Sprite.size + 1), y: 0)
                node.addChild(lifeUnavailable)
            }
        }
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

struct Score {
    private var score = 10000
    private(set) var coordinate: Coordinate = Coordinate(x: 64, y: 9)
    private(set) var node: SKNode!

    init() {
        node = SKNode()
        node.position = coordinate.toPosition()
        node.zPosition = Layers.interface.rawValue
        drawScore()
    }

    private func drawScore() {
        let display = SKLabelNode(fontNamed: "PICO-8")
        display.fontSize = 6
        display.fontColor = Color.lightBlue
        display.text = "score:\(score)"
        node.addChild(display)
    }
}

class Player {
    private(set) var coordinate: Coordinate = Coordinate(x: Screen.size/2, y: Screen.size/2)
    private(set) var direction: Direction = .none
    private(set) var node: SKNode!
    private var soundPlayer: SoundPlayer
    private var ship: SKSpriteNode!
    private var flame: SKSpriteNode!
    private var flash: SKSpriteNode!
    private var flameSprite: Int = 0
    private var flashSprite: Int = 0

    init(soundPlayer: SoundPlayer) {
        self.soundPlayer = soundPlayer
        node = SKNode()
        node.zPosition = Layers.sprites.rawValue
        node.position = coordinate.toPosition()
        ship = SKSpriteNode(imageNamed: "ship_0")
        flame = SKSpriteNode(imageNamed: "flame_0")
        flash = SKSpriteNode(imageNamed: "flash_0")
        flame.position = CGPoint(x: flame.position.x, y: flame.position.y - CGFloat(Sprite.size))
        flash.position = CGPoint(x: flash.position.x, y: flash.position.y + CGFloat(Sprite.size - 2))
        flash.isHidden = true
        Screen.setup(sprite: ship)
        Screen.setup(sprite: flame)
        Screen.setup(sprite: flash)
        node.addChild(ship)
        node.addChild(flame)
        node.addChild(flash)
    }

    func point(direction: Direction) {
        switch direction {
        case .left:
            ship.texture = SKTexture(imageNamed: "ship_1")
        case .right:
            ship.texture = SKTexture(imageNamed: "ship_2")
        default:
            ship.texture = SKTexture(imageNamed: "ship_0")
        }
        ship.texture?.filteringMode = .nearest
        self.direction = direction
    }

    func update() {
        move()
        animateFlame()
        animateFlash()
    }

    func fire() -> PlasmaBall {
        flash.isHidden = false
        node.run(soundPlayer.laser)
        return PlasmaBall(coordinate: coordinate)
    }

    private func move() {
        coordinate = coordinate
            .move(direction: direction)
            .wrapIfNeeded()
        node.position = coordinate.toPosition()
    }

    private func animateFlame() {
        flameSprite += 1
        if flameSprite > 4 {
            flameSprite = 0
        }
        flame.texture = SKTexture(imageNamed: "flame_\(flameSprite)")
        flame.texture?.filteringMode = .nearest
    }

    private func animateFlash() {
        if flash.isHidden {
            return
        }
        flashSprite += 1
        if flashSprite > 3 {
            flashSprite = 0
            flash.isHidden = true
        }
        flash.texture = SKTexture(imageNamed: "flash_\(flashSprite)")
        flash.texture?.filteringMode = .nearest
    }
}

class PlasmaBall {
    private(set) var coordinate: Coordinate
    private(set) var node: SKNode!
    private var ball: SKSpriteNode!

    init(coordinate: Coordinate) {
        self.coordinate = coordinate
        node = SKNode()
        node.zPosition = Layers.sprites.rawValue
        ball = SKSpriteNode(imageNamed: "fire")

        Screen.setup(sprite: ball)
        node.addChild(ball)
        move()
    }

    func update() {
        move()
    }

    func remove() {
        node.removeFromParent()
    }

    private func move() {
        coordinate = coordinate.move(direction: .up, pixels: Sprite.size/2)
        node.position = coordinate.toPosition()
    }
}

class Star {
    private static let slowStarSpeed: Double = 0.5
    private static let normalStarSpeed: Double = 1.5
    private static let fastStarSpeed: Double = 2.5
    static let starSpeeds = slowStarSpeed...fastStarSpeed
    private(set) var node: SKSpriteNode!
    var speed: Double

    init(coordinate: Coordinate, speed: Double) {
        self.speed = speed
        switch speed {
        case 0..<Star.slowStarSpeed:
            node = SKSpriteNode(imageNamed: "star_2")
        case Star.slowStarSpeed..<Star.normalStarSpeed:
            node = SKSpriteNode(imageNamed: "star_1")
        default:
            node = SKSpriteNode(imageNamed: "star_0")
        }
        node.position = coordinate.toPosition()
        node.speed = self.speed
    }

    func update() {
        node.position.y = node.position.y < 0 ? CGFloat(Screen.size) : node.position.y - speed
    }
}

struct StarField {
    private static let totalStars = 100
    private(set) var node: SKNode!
    private var stars = [Star]()

    init() {
        node = SKScene(size: .init(width: Screen.size, height: Screen.size))
        for _ in 0..<StarField.totalStars {
            let star = Star(
                coordinate: Screen.randomCoordinate(),
                speed: Double.random(in: Star.starSpeeds)
            )
            stars.append(star)
            node.addChild(star.node)
        }
    }

    func update() {
        stars.forEach { $0.update() }
    }
}

class GameScene: SKScene {
    private var player: Player!
    private var plasmaBalls = [PlasmaBall]()
    private var screen = Screen()
    private var lives = Lives()
    private var score = Score()
    private var soundPlayer = SoundPlayer()
    private var starField = StarField()

    class func newGameScene() -> GameScene {
        let scene = GameScene(size: CGSize(width: Screen.size, height: Screen.size))
        scene.anchorPoint = .init(x: 0, y: 0)
        scene.scaleMode = .aspectFill
        scene.screen.use(scene: scene)
        scene.backgroundColor = Color.black
        return scene
    }

    func setUpScene() {
        view?.preferredFramesPerSecond = Screen.framesPerSecond
        player = Player(soundPlayer: soundPlayer)
        starField = StarField()
        addChild(player.node)
        addChild(lives.node)
        addChild(score.node)
        addChild(starField.node)
    }

    override func didMove(to view: SKView) {
        self.setUpScene()
    }

    override func update(_ currentTime: TimeInterval) {
        player.update()
        for (index, plasmaBall) in plasmaBalls.enumerated() {
            plasmaBall.update()
            if plasmaBall.coordinate.y < Screen.origin.y - Sprite.size {
                plasmaBall.remove()
                plasmaBalls.remove(at: index)
            }

        }
        starField.update()
    }

    override func keyUp(with event: NSEvent) {
        let keyCode = KeyCodes(rawValue: event.keyCode)
        if keyCode?.toDirection() == player.direction {
            player.point(direction: .none)
        }
    }

    override func keyDown(with event: NSEvent) {
        let keyCode = KeyCodes(rawValue: event.keyCode)
        let direction = keyCode?.toDirection() ?? Direction.none
        if direction != .none {
            player.point(direction: direction)
        }
        if keyCode == KeyCodes.zKey {
            let plasma = player.fire()
            self.plasmaBalls.append(plasma)
            addChild(plasma.node)
        }
    }
}
