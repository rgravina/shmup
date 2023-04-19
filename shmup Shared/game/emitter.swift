import SpriteKit

enum ParticleEmitterColor {
    case red, blue
}

class Particle {
    private(set) var node: SKShapeNode!
    static let speeds = 0...6.0
    private var emitterColor: ParticleEmitterColor
    var xSpeed: Double
    var ySpeed: Double
    let maxAge: Int
    var age: Int
    private(set) var size: Double

    init(coordinate: Coordinate, color: ParticleEmitterColor, xSpeed: Double, ySpeed: Double, age: Int, size: Double, maxAge: Int) {
        self.emitterColor = color
        self.xSpeed = xSpeed
        self.ySpeed = ySpeed
        self.age = age
        self.size = size
        self.maxAge = maxAge
        node = SKShapeNode(circleOfRadius: size)
        node.strokeColor = self.color
        node.fillColor = self.color
        node.position = coordinate.toPosition()
        node.zPosition = Layers.background.rawValue
    }

    convenience init(coordinate: Coordinate, color: ParticleEmitterColor, xSpeed: Double, ySpeed: Double) {
        self.init(
            coordinate: coordinate,
            color: color,
            xSpeed: xSpeed,
            ySpeed: ySpeed,
            age: Int.random(in: 0...2),
            size: 1 + Double.random(in: 0...4),
            maxAge: 10 + Int.random(in: 0...10)
        )
    }

    convenience init(coordinate: Coordinate, color: ParticleEmitterColor, size: Double, age: Int, maxAge: Int) {
        self.init(
            coordinate: coordinate,
            color: color,
            xSpeed: 0,
            ySpeed: 0,
            age: age,
            size: size,
            maxAge: maxAge
        )
    }

    func update() {
        node.position.x = node.position.x + xSpeed
        node.position.y = node.position.y + ySpeed
        node.strokeColor = color
        node.fillColor = color
        xSpeed *= 0.85
        ySpeed *= 0.85
        age += 1
    }

    private var color: NSColor {
        get {
            switch emitterColor {
            case .red:
                switch age {
                case 0..<5:
                    return Color.white
                case 5..<7:
                    return Color.yellow
                case 7..<10:
                    return Color.orange
                case 10..<12:
                    return Color.red
                case 12..<15:
                    return Color.purple
                default:
                    return Color.darkGrey
                }
            case .blue:
                switch age {
                case 0..<5:
                    return Color.white
                case 5..<7:
                    return Color.lightGrey
                case 7..<10:
                    return Color.lightBlue
                case 10..<12:
                    return Color.mediumGrey
                case 12..<15:
                    return Color.darkBlue
                default:
                    return Color.darkBlue
                }
            }
        }
    }

    func decrease(by: Double) {
        size -= by
        node.run(SKAction.scale(by: by, duration: 0))
    }
}

class ParticleEmitter {
    private static let totalParticles = 30
    private(set) var node: SKNode!
    private var particles = [Particle]()

    init() {
        node = SKScene(size: .init(width: Screen.size, height: Screen.size))
    }

    func emit(coordinate: Coordinate, color: ParticleEmitterColor) {
        for _ in 0..<ParticleEmitter.totalParticles {
            let particle = Particle(
                coordinate: Coordinate(x: coordinate.x + Sprite.size/2, y: coordinate.y + Sprite.size/2),
                color: color,
                xSpeed: Double.random(in: Particle.speeds) - Particle.speeds.upperBound/2,
                ySpeed: Double.random(in: Particle.speeds) - Particle.speeds.upperBound/2
            )
            particles.append(particle)
            node.addChild(particle.node)
        }
        let particle = Particle(
            coordinate: coordinate,
            color: color,
            size: 8,
            age: 0,
            maxAge: 5
        )
        particles.append(particle)
        node.addChild(particle.node)
    }

    func update() {
        for (index, particle) in particles.enumerated().reversed() {
            particle.update()
            if particle.age > particle.maxAge {
                particle.decrease(by: 0.5)
                if particle.size < 0 {
                    particle.node.removeFromParent()
                    particles.remove(at: index)
                }
            }
        }
    }
}
