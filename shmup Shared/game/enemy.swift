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
    var position: CGPoint { get }
    var collisionBoxWidth: Int { get }
}

class EnemySpriteAnimation: Drawable, SpriteAnimation {
    private var sprite: Double = 0
    private var node: SKSpriteNode!

    init() {
        node = SKSpriteNode(imageNamed: "enemy_\(Int(sprite))")
        Screen.setup(sprite: node)
    }

    var collisionBoxWidth: Int {
        return Sprite.size
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

class EnemySpriteSheetAnimation: Drawable, SpriteAnimation {
    private var row: Int
    private var col: Int
    private let cells: Int
    private var frames: Double
    private var sprite: Double = 0
    static let frameLength: Double = 10
    private var node: SKSpriteNode!
    static let sheet = SpriteSheet(
        imageNamed: "enemysprites",
        rows: 7,
        cols: 16
    )

    init(row: Int, col: Int, frames: Int, cells: Int = 1) {
        self.row = row
        self.col = col
        self.frames = Double(frames)
        self.cells = cells
        node = EnemySpriteSheetAnimation.sheet.sprite(row: row, col: col, cells: cells)
        Screen.setup(sprite: node)
    }

    var collisionBoxWidth: Int {
        return cells * Sprite.size
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
        sprite = sprite >= frames ?
            0 :
            sprite + (frames/EnemySpriteSheetAnimation.frameLength)
        node.texture = EnemySpriteSheetAnimation.sheet.texture(row: row, col: col + Int(sprite) * cells, cells: cells)
        Screen.setup(sprite: node)
        node.position = coordinate.toPosition()
    }

    func remove() {
        node.removeFromParent()
    }
}

enum EnemyType {
    case none, greenAlien, redAlien, spinningShip, largeShip
}

class Enemy: Drawable, Collidable {
    let collisionBoxWidth: Int
    private(set) var coordinate: Coordinate
    private var animation: SpriteAnimation
    private(set) var hitPoints: Int
    private(set) var destroyed = false

    init(coordinate: Coordinate, animation: SpriteAnimation, hitPoints: Int) {
        self.coordinate = coordinate
        self.animation = animation
        self.hitPoints = hitPoints
        self.collisionBoxWidth = animation.collisionBoxWidth
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
        coordinate = Coordinate(x: coordinate.x, y: -Sprite.size)
    }
}

class Enemies: Drawable, Pixelatable {
    private var node: SKNode!
    private var waveText: WaveText!
    private var enemies = [Enemy]()
    private(set) var wave = 1

    init() {
        node = SKNode()
        node.zPosition = Layers.sprites.rawValue
        waveText = WaveText(wave: wave)
        waveText.add(parent: node)
        drawWave(enemies: ememiesForWave())
    }

    func add(parent: SKNode) {
        parent.addChild(node)
    }

    func pixelate(using view: SKView) {
        waveText.pixelate(using: view)
    }

    func collides(ball: PlasmaBall, onCollision: (Enemy, PlasmaBall) -> Void) {
        for (index, enemy) in enemies.enumerated().reversed() {
            if Collision.collides(a: ball, b: enemy) {
                enemy.hit()
                if enemy.hitPoints == 0 {
                    enemy.remove()
                    enemies.remove(at: index)
                }
                onCollision(enemy, ball)
                break
            }
        }
    }

    func update(player: Player, onCollision: () -> Void, onNewWave: () -> Void) {
        waveText.update()
        if enemies.isEmpty {
            wave += 1
            drawWave(enemies: ememiesForWave())
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

    func drawWave(enemies: [[EnemyType]]) {
        waveText.nextWave(wave: wave)
        for (row, rows) in enemies.enumerated() {
            for (col, enemyType) in rows.enumerated() {
                guard enemyType != .none else { continue }
                createEnemy(
                    coordinate: Coordinate(
                        x: (col * Sprite.size + col * 4) + 6,
                        y: (row * Sprite.size + row * 4) + 12
                    ),
                    enemyType: enemyType,
                    hitPoints: hitPointsForEnemyType(enemyType: enemyType)
                )
            }
        }
    }

    func remove() {
        node.removeFromParent()
    }

    private func createEnemy(coordinate: Coordinate, enemyType: EnemyType, hitPoints: Int) {
        let enemy = Enemy(
            coordinate: coordinate,
            animation: ememyForType(enemyType: enemyType),
            hitPoints: hitPointsForEnemyType(enemyType: enemyType)
        )
        enemies.append(enemy)
        enemy.add(parent: node)
    }

    private func hitPointsForEnemyType(enemyType: EnemyType) -> Int {
        switch enemyType {
        case .largeShip:
            return 5
        case .spinningShip:
            return 3
        case .redAlien:
            return 2
        case .greenAlien:
            return 1
        default:
            return 1
        }
    }

    private func ememyForType(enemyType: EnemyType) -> SpriteAnimation {
        switch enemyType {
        case .largeShip:
            return EnemySpriteSheetAnimation(row: 5, col: 0, frames: 2, cells: 2)
        case .spinningShip:
            return EnemySpriteSheetAnimation(row: 3, col: 8, frames: 4)
        case .redAlien:
            return EnemySpriteSheetAnimation(row: 1, col: 4, frames: 2)
        case .greenAlien:
            return EnemySpriteAnimation()
        default:
            return EnemySpriteAnimation()
        }
    }

    private func ememiesForWave() -> [[EnemyType]] {
        switch wave {
        case 4:
            return [
                [.none, .none, .spinningShip, .largeShip, .none, .spinningShip, .none, .none],
                [.none, .none, .spinningShip, .largeShip, .none, .spinningShip, .none, .none],
                [.none, .none, .spinningShip, .largeShip, .none, .spinningShip, .none, .none],
                [.none, .none, .spinningShip, .largeShip, .none, .spinningShip, .none, .none],
            ]
        case 3:
            return [
                [.greenAlien, .greenAlien, .redAlien, .redAlien, .redAlien, .greenAlien, .redAlien, .spinningShip, .greenAlien, .greenAlien],
                [.spinningShip, .greenAlien, .spinningShip, .greenAlien, .spinningShip, .redAlien, .redAlien, .redAlien, .greenAlien, .redAlien],
                [.spinningShip, .greenAlien, .spinningShip, .redAlien, .spinningShip, .spinningShip, .redAlien, .redAlien, .greenAlien, .spinningShip],
                [.redAlien, .greenAlien, .redAlien, .redAlien, .redAlien, .spinningShip, .redAlien, .redAlien, .greenAlien, .redAlien],
           ]
        case 2:
            return [
                [.greenAlien, .greenAlien, .redAlien, .redAlien, .redAlien, .greenAlien, .redAlien, .redAlien, .greenAlien, .greenAlien],
                [.greenAlien, .greenAlien, .redAlien, .greenAlien, .spinningShip, .redAlien, .redAlien, .redAlien, .greenAlien, .redAlien],
                [.spinningShip, .greenAlien, .redAlien, .redAlien, .spinningShip, .spinningShip, .redAlien, .redAlien, .greenAlien, .spinningShip],
                [.redAlien, .greenAlien, .redAlien, .redAlien, .redAlien, .spinningShip, .redAlien, .redAlien, .greenAlien, .redAlien],
           ]
        default:
            return [
                [.none, .greenAlien, .redAlien, .redAlien, .spinningShip, .redAlien, .redAlien, .redAlien, .greenAlien, .none],
                [.none, .greenAlien, .redAlien, .redAlien, .redAlien, .spinningShip, .redAlien, .redAlien, .greenAlien, .none],
                [.none, .greenAlien, .greenAlien, .redAlien, .greenAlien, .spinningShip, .redAlien, .redAlien, .greenAlien, .none],
                [.none, .greenAlien, .redAlien, .greenAlien, .spinningShip, .greenAlien, .redAlien, .redAlien, .greenAlien, .none],
           ]
        }
    }
}
