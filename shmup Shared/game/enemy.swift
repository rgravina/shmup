import SpriteKit

class WaveText: Drawable, Pixelatable {
    private var node: SKNode!
    private var text: Text!
    private static var maxAge = 80
    private var age = 0
    private var wave: Int

    init(wave: Int) {
        self.wave = wave
        node = SKScene(size: .init(width: Screen.size, height: Screen.size))
        text = Text(
            text: "wave \(self.wave)",
            color: Color.darkGrey,
            coordinate: Coordinate(x: 64, y: 32)
        )
        text.add(parent: node)
    }

    func add(parent: SKNode) {
        parent.addChild(node)
    }

    var position: CGPoint {
        return node.position
    }

    func pixelate(using view: SKView) {
        text.pixelate(using: view)
    }

    func update() {
        guard !node.isHidden else { return }
        text.blink()
        age += 1
        if age > WaveText.maxAge {
            node.isHidden = true
        }
    }

    func nextWave(wave: Int) {
        self.wave = wave
        text.text = "wave \(wave)"
        age = 0
        node.isHidden = false
    }

    func remove() {
        node.removeFromParent()
    }
}

struct Animation {
    static let flash = SKAction.sequence([
        SKAction.colorize(with: Color.black, colorBlendFactor: 1, duration: 0),
        SKAction.wait(forDuration: 0.2),
        SKAction.colorize(withColorBlendFactor: 0, duration: 0)
    ])
}

protocol SpriteAnimation: Drawable {
    func start(coordinate: Coordinate) -> SKSpriteNode
    func flash()
    func next(coordinate: Coordinate)
}

class EnemySpriteAnimation: Drawable, SpriteAnimation {
    private var sprite: Double = 0
    private var node: SKSpriteNode!

    init() {
        node = SKSpriteNode(imageNamed: "enemy_\(Int(sprite))")
        Screen.setup(sprite: node)
    }

    func add(parent: SKNode) {
        parent.addChild(node)
    }

    var position: CGPoint {
        return node.position
    }

    func start(coordinate: Coordinate) -> SKSpriteNode {
        node.position = coordinate.toPosition()
        return node
    }

    func flash() {
        node.run(Animation.flash)
    }

    func next(coordinate: Coordinate) {
        sprite = sprite >= 3.8 ? 0 : sprite + 0.4
        node.texture = SKTexture(imageNamed: "enemy_\(Int(sprite))")
        node.texture?.filteringMode = .nearest
        node.position = coordinate.toPosition()
    }

    func remove() {
        node.removeFromParent()
    }
}

class Enemy: Drawable {
    private(set) var coordinate: Coordinate
    private var animation: SpriteAnimation
    private(set) var hitPoints: Int = 5
    private(set) var destroyed = false

    init(coordinate: Coordinate, animation: SpriteAnimation) {
        self.coordinate = coordinate
        self.animation = animation
    }

    func add(parent: SKNode) {
        parent.addChild(animation.start(
            coordinate: coordinate
        ))
    }

    var position: CGPoint {
        return animation.position
    }

    func hit() {
        hitPoints -= 1
        animation.flash()
    }

    func move() {
        coordinate = coordinate.move(direction: .down, pixels: 1)
        animation.next(coordinate: coordinate)
    }

    func remove() {
        destroyed = true
        animation.remove()
    }

    func moveToTop() {
        coordinate = Screen.randomStartingCoordinate()
    }
}

class Enemies: Drawable, Pixelatable {
    private var node: SKNode!
    private var waveText: WaveText!
    private var enemies = [Enemy]()
    private(set) var wave = 0

    init() {
        node = SKNode()
        node.zPosition = Layers.sprites.rawValue
        waveText = WaveText(wave: wave)
        waveText.add(parent: node)
        nextWave()
    }

    func add(parent: SKNode) {
        parent.addChild(node)
    }

    var position: CGPoint {
        return node.position
    }

    func pixelate(using view: SKView) {
        waveText.pixelate(using: view)
    }

    func collides(ball: PlasmaBall, onCollision: (Enemy, PlasmaBall) -> Void) {
        for (index, enemy) in enemies.enumerated().reversed() {
            if Collision.collides(a: ball, b: enemy) {
                if enemy.hitPoints == 0 {
                    enemy.remove()
                    enemies.remove(at: index)
                    onCollision(enemy, ball)
                } else {
                    enemy.hit()
                    onCollision(enemy, ball)
                }
                break
            }
        }
    }

    func update(player: Player, onCollision: () -> Void, onNewWave: () -> Void) {
        waveText.update()
        if enemies.isEmpty {
            nextWave()
            onNewWave()
        }
        for (_, enemy) in enemies.enumerated().reversed() {
            enemy.move()
            if enemy.coordinate.y > Screen.size {
                enemy.moveToTop()
                break
            }
            if !player.isInvunerable {
                if Collision.collides(a: player, b: enemy) {
                    onCollision()
                    break
                }
            }
        }
    }

    func createWave() {
        createEnemy()
    }

    func nextWave() {
        wave += 1
        waveText.nextWave(wave: wave)
        createEnemy()
    }

    func remove() {
        node.removeFromParent()
    }

    private func createEnemy() {
        let enemy = Enemy(
            coordinate: Screen.randomStartingCoordinate(),
            animation: EnemySpriteAnimation()
        )
        enemies.append(enemy)
        enemy.add(parent: node)
    }
}
