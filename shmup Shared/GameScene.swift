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
    private(set) var coordinate: Coordinate = Coordinate(x: 4, y: 4)
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

struct StarField {
    private static let totalStars = 100
    private(set) var node: SKNode!
    private var stars = [SKSpriteNode]()

    init() {
        node = SKScene(size: .init(width: Screen.size, height: Screen.size))
        node.zPosition = Layers.background.rawValue
        for _ in 0..<StarField.totalStars {
            let star: SKSpriteNode
            let speed = CGFloat(Double.random(in: 0..<2))
            switch(speed) {
            case 0..<0.5:
                star = SKSpriteNode(imageNamed: "star_2")
            case 0.5..<1.5:
                star = SKSpriteNode(imageNamed: "star_1")
            default:
                star = SKSpriteNode(imageNamed: "star_0")
            }
            star.position = .init(x: Int.random(in: 0..<Screen.size), y: Int.random(in: 0..<Screen.size))
            star.speed = speed
            stars.append(star)
            node.addChild(star)
        }
    }

    func update() {
        for star in stars {
            let newY = star.position.y < 0 ? CGFloat(Screen.size) : star.position.y-star.speed
            star.position = CGPoint(x: star.position.x, y: newY)
        }
    }
}

class GameScene: SKScene {
    private var player: Player!
    private var plasma: PlasmaBall?
    private var screen = Screen()
    private var lives = Lives()
    private var soundPlayer = SoundPlayer()
    private var starField = StarField()

    class func newGameScene() -> GameScene {
        let scene = GameScene(size: CGSize(width: Screen.size, height: Screen.size))
        scene.anchorPoint = .init(x: 0, y: 0)
        scene.scaleMode = .aspectFill
        scene.screen.use(scene: scene)
        return scene
    }

    func setUpScene() {
        view?.preferredFramesPerSecond = Screen.framesPerSecond
        player = Player(soundPlayer: soundPlayer)
        starField = StarField()
        addChild(player.node)
        addChild(lives.node)
        addChild(starField.node)
    }

    override func didMove(to view: SKView) {
        self.setUpScene()
    }

    override func update(_ currentTime: TimeInterval) {
        player.update()
        if let plasma = plasma {
            plasma.update()
            if plasma.coordinate.y < Screen.origin.y {
                plasma.remove()
                self.plasma = nil
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
        if keyCode == KeyCodes.zKey && plasma == nil {
            plasma = player.fire()
            addChild(plasma!.node)
        }
    }
}
