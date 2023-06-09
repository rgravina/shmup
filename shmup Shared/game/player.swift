import SpriteKit
import Foundation

class Player: Drawable, Collidable {
    private(set) var coordinate: Coordinate = Coordinate(x: Screen.size/2, y: Screen.size/2)
    private(set) var direction: Direction = .none
    private var node: SKNode!
    private var soundPlayer: SoundPlayer
    private var ship: SKSpriteNode!
    private var flame: SKSpriteNode!
    private var flash: SKSpriteNode!
    private var flameSprite: Int = 0
    private var flashSprite: Int = 0
    private var invulnerability: Int = 0
    private var firing = false
    private var firingTimer: Int = 0
    let collisionBoxWidth = 8

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

    func add(parent: SKNode) {
        parent.addChild(node)
    }

    var position: CGPoint {
        return node.position
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
        decreaseInvulnerability()
        fire()
        move()
        animateFlame()
        animateFlash()
    }

    func remove() {
        node.removeFromParent()
    }

    private func fire() {
        if firing {
            if shouldFire {
                flash.isHidden = false
                node.run(soundPlayer.laser)
                firingTimer = 3
            }
            firingTimer -= 1
        }
    }

    var shouldFire: Bool {
        get {
            return firing && firingTimer == 0
        }
    }

    func startFiring() {
        guard !firing else {
            return
        }
        firing = true
        firingTimer = 0
    }

    func endFiring() {
        firing = false
        firingTimer = 0
    }

    func hit() {
        invulnerability = Screen.framesPerSecond * 2
    }

    var isInvunerable: Bool {
        get {
            return invulnerability > 0
        }
    }

    private func decreaseInvulnerability() {
        if invulnerability > 0 {
            invulnerability -= 1
            node.isHidden = sin(Double(invulnerability)) < 0
        }
    }

    private func move() {
        coordinate = coordinate
            .move(direction: direction)
            .contain()
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

class PlasmaBall: Drawable, Collidable {
    private(set) var coordinate: Coordinate
    private var node: SKNode!
    private var ball: SKSpriteNode!
    let collisionBoxWidth = 8

    init(coordinate: Coordinate) {
        self.coordinate = coordinate
        node = SKNode()
        node.zPosition = Layers.sprites.rawValue
        ball = SKSpriteNode(imageNamed: "fire")

        Screen.setup(sprite: ball)
        node.addChild(ball)
        move()
    }

    func add(parent: SKNode) {
        parent.addChild(node)
    }

    var position: CGPoint {
        return node.position
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

class PlasmaBalls: Drawable {
    private var node: SKNode!
    private var plasmaBalls = [PlasmaBall]()

    init() {
        node = SKScene(size: .init(width: Screen.size, height: Screen.size))
    }

    func append(_ plasmaBall: PlasmaBall) {
        plasmaBalls.append(plasmaBall)
    }

    func add(parent: SKNode) {
        parent.addChild(node)
    }

    func update(player: Player, enemies: Enemies, onCollision: (Enemy, PlasmaBall) -> Void) {
        if player.shouldFire {
            let plasmaBall = PlasmaBall(coordinate: player.coordinate)
            plasmaBalls.append(plasmaBall)
            plasmaBall.add(parent: node)
        }

        for (index, plasmaBall) in plasmaBalls.enumerated().reversed() {
            plasmaBall.update()
            if plasmaBall.coordinate.y < Screen.origin.y - Sprite.size {
                plasmaBall.remove()
                plasmaBalls.remove(at: index)
            }
            enemies.collides(ball: plasmaBall) { enemy, ball in
                plasmaBall.remove()
                plasmaBalls.remove(at: index)
                onCollision(enemy, ball)
            }
        }
    }

    func remove() {
        node.removeFromParent()
    }
}
