import SpriteKit

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
