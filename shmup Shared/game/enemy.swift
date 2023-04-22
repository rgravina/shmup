import SpriteKit

class WaveText {
    private(set) var node: SKNode!
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
        node.addChild(text.node)
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
}

struct Animation {
    static let flash = SKAction.sequence([
        SKAction.colorize(with: Color.black, colorBlendFactor: 1, duration: 0),
        SKAction.wait(forDuration: 0.2),
        SKAction.colorize(withColorBlendFactor: 0, duration: 0)
    ])
}

class Enemy {
    private(set) var coordinate: Coordinate
    private(set) var node: SKSpriteNode!
    private var sprite: Double = 0
    private(set) var hitPoints: Int = 5
    private(set) var destroyed = false

    init(coordinate: Coordinate) {
        self.coordinate = coordinate
        node = SKSpriteNode(imageNamed: "enemy_\(Int(sprite))")
        Screen.setup(sprite: node)
        node.position = coordinate.toPosition()
    }

    func hit() {
        hitPoints -= 1
        node.run(Animation.flash)
    }

    func move() {
        sprite = sprite >= 3.8 ? 0 : sprite + 0.4
        node.texture = SKTexture(imageNamed: "enemy_\(Int(sprite))")
        node.texture?.filteringMode = .nearest
        coordinate = coordinate.move(direction: .down, pixels: 1)
        node.position = coordinate.toPosition()
    }

    func remove() {
        destroyed = true
        node.removeFromParent()
    }

    func moveToTop() {
        coordinate = Screen.randomStartingCoordinate()
    }
}

class Enemies {
    private(set) var node: SKNode!
    private var waveText: WaveText!
    private var enemies = [Enemy]()
    private(set) var wave = 0

    init() {
        node = SKNode()
        node.zPosition = Layers.sprites.rawValue
        waveText = WaveText(wave: wave)
        node.addChild(waveText.node)
        nextWave()
    }

    func collides(ball: PlasmaBall, onCollision: (Enemy, PlasmaBall) -> Void) {
        for (index, enemy) in enemies.enumerated().reversed() {
            if Collision.collides(a: ball.node, b: enemy.node) {
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

    func update(player: Player, onCollision: () -> Void) {
        waveText.update()
        if enemies.isEmpty {
            nextWave()
        }
        for (_, enemy) in enemies.enumerated().reversed() {
            enemy.move()
            if enemy.coordinate.y > Screen.size {
                enemy.moveToTop()
                break
            }
            if !player.isInvunerable {
                if Collision.collides(a: player.node, b: enemy.node) {
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

    private func createEnemy() {
        let enemy = Enemy(coordinate: Screen.randomStartingCoordinate())
        enemies.append(enemy)
        node.addChild(enemy.node)
    }
}
