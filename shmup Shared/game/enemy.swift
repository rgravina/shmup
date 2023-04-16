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
        createEnemy()
    }

    func collides(node: SKNode, onCollision: () -> Void) {
        for (index, enemy) in enemies.enumerated().reversed() {
            if Collision.collides(a: node, b: enemy.node) {
                enemy.remove()
                enemies.remove(at: index)
                onCollision()
                break
            }
        }
    }

    func update(player: Player, onCollision: () -> Void) {
        if enemies.isEmpty {
            createEnemy()
        }
        for (index, enemy) in enemies.enumerated().reversed() {
            enemy.move()
            if enemy.coordinate.y > Screen.size {
                enemy.remove()
                enemies.remove(at: index)
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

    private func createEnemy() {
        let enemy = Enemy(coordinate: Coordinate(x: Int.random(in: 0..<Screen.size), y: 0))
        enemies.append(enemy)
        node.addChild(enemy.node)
    }
}
