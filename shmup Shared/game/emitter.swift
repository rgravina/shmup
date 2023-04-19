import SpriteKit

class Particle {
    private(set) var node: SKSpriteNode!
    static let speeds = 0...3.0
    var xSpeed: Double
    var ySpeed: Double
    let maxAge: Int
    var age = 0

    init(coordinate: Coordinate, xSpeed: Double, ySpeed: Double) {
        self.xSpeed = xSpeed
        self.ySpeed = ySpeed
        maxAge = 20 + Int.random(in: 0...10)
        node = SKSpriteNode(imageNamed: "star_0")
        node.position = coordinate.toPosition()
        node.zPosition = Layers.background.rawValue
    }

    func update() {
        node.position.x = node.position.x + xSpeed
        node.position.y = node.position.y + ySpeed
        age += 1
    }
}

class ParticleEmitter {
    private static let totalParticles = 30
    private(set) var node: SKNode!
    private var particles = [Particle]()

    init() {
        node = SKScene(size: .init(width: Screen.size, height: Screen.size))
    }

    func emit(coordinate: Coordinate) {
        for _ in 0..<ParticleEmitter.totalParticles {
            let particle = Particle(
                coordinate: coordinate,
                xSpeed: Double.random(in: Particle.speeds) - 1.5,
                ySpeed: Double.random(in: Particle.speeds) - 1.5
            )
            particles.append(particle)
            node.addChild(particle.node)
        }
    }

    func update() {
        for (index, particle) in particles.enumerated().reversed() {
            particle.update()
            if particle.age > particle.maxAge {
                particle.node.removeFromParent()
                particles.remove(at: index)
            }
        }
    }
}
