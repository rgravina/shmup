import SpriteKit

class Enemy {
    private(set) var coordinate: Coordinate
    private(set) var node: SKSpriteNode!
    private var sprite: Double = 0

    init(coordinate: Coordinate) {
        self.coordinate = coordinate
        node = SKSpriteNode(imageNamed: "enemy_\(Int(sprite))")
        Screen.setup(sprite: node)
        node.position = coordinate.toPosition()
    }

    func move() {
        sprite = sprite >= 3.8 ? 0 : sprite + 0.4
        node.texture = SKTexture(imageNamed: "enemy_\(Int(sprite))")
        node.texture?.filteringMode = .nearest
        coordinate = coordinate.move(direction: .down, pixels: 1)
        node.position = coordinate.toPosition()
    }

    func remove() {
        node.removeFromParent()
    }
}

class Enemies {
    private(set) var node: SKNode!
    private var enemies = [Enemy]()

    init() {
        node = SKNode()
        node.zPosition = Layers.sprites.rawValue
        let enemy = Enemy(coordinate: Coordinate(x: Screen.size/2, y: Sprite.size))
        enemies.append(enemy)
        node.addChild(enemy.node)
    }

    func update(player: Player, onCollision: () -> Void) {
        for (index, enemy) in enemies.enumerated().reversed() {
            enemy.move()
            if enemy.coordinate.y > Screen.size {
                enemy.remove()
                enemies.remove(at: index)
                break
            }
            if Collision.collides(a: player.node, b: enemy.node) {
                enemy.remove()
                enemies.remove(at: index)
                onCollision()
                break
            }
        }
    }
}
