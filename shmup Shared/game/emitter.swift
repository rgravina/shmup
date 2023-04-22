import SpriteKit

protocol Particle {
    func update()
    func remove()
    func add(parent: SKNode)
    var alive: Bool { get }
}

class Spark: Particle {
    private let node: SKSpriteNode
    static let speeds = 0...6.0
    var xSpeed: Double
    var ySpeed: Double
    private let maxAge: Int
    private var age: Int

    convenience init(coordinate: Coordinate) {
        self.init(
            coordinate: coordinate,
            xSpeed: Double.random(in: Spark.speeds) - Spark.speeds.upperBound/2,
            ySpeed: Double.random(in: Spark.speeds) - Spark.speeds.upperBound/2
        )
    }

    init(coordinate: Coordinate, xSpeed: Double, ySpeed: Double) {
        node = SKSpriteNode(imageNamed: "spark")
        node.position = coordinate.moveToSpriteCenter().toPosition()
        node.zPosition = Layers.background.rawValue
        age = Int.random(in: 0...2)
        maxAge = 10 + Int.random(in: 0...10)
        self.xSpeed = xSpeed
        self.ySpeed = ySpeed
    }

    func update() {
        node.position.x = node.position.x + xSpeed
        node.position.y = node.position.y + ySpeed
        xSpeed *= 0.85
        ySpeed *= 0.85
        age += 1
    }

    func remove() {
        node.removeFromParent()
    }

    func add(parent: SKNode) {
        parent.addChild(node)
    }

    var alive: Bool {
        return age <= maxAge
    }
}

class LargeWave: Particle {
    private var node: SKShapeNode
    let startRadius: CGFloat = 2
    private let maxAge: Int = 5
    private var age: Int = 0

    init(coordinate: Coordinate) {
        node = SKShapeNode(circleOfRadius: startRadius)
        node.strokeColor = Color.white
        node.position = coordinate.moveToSpriteCenter().toPosition()
        node.zPosition = Layers.background.rawValue
    }

    func update() {
        age += 1
        let parent = node.parent
        let position = node.position
        node.removeFromParent()
        node = SKShapeNode(circleOfRadius: startRadius + CGFloat(age * 5))
        node.position = position
        parent?.addChild(node)
    }

    func remove() {
        node.removeFromParent()
    }

    func add(parent: SKNode) {
        parent.addChild(node)
    }

    var alive: Bool {
        return age <= maxAge
    }
}

class Wave: Particle {
    private let node: SKSpriteNode
    private let maxAge: Int = 10
    private var age: Int = 0

    init(coordinate: Coordinate) {
        node = SKSpriteNode(imageNamed: "circle_0")
        node.position = coordinate.moveToSpriteCenter().toPosition()
        node.zPosition = Layers.background.rawValue
        node.texture?.filteringMode = .nearest
        node.color = Color.orange
        node.colorBlendFactor = 1
    }

    func update() {
        age += 1
        switch age {
        case 0..<2:
            node.texture = SKTexture(imageNamed: "circle_0")
        case 2..<4:
            node.texture = SKTexture(imageNamed: "circle_1")
        case 4..<6:
            node.texture = SKTexture(imageNamed: "circle_2")
        case 6..<8:
            node.texture = SKTexture(imageNamed: "circle_3")
        case 8..<10:
            node.texture = SKTexture(imageNamed: "circle_4")
        default:
            break
        }
        node.texture?.filteringMode = .nearest
    }

    func remove() {
        node.removeFromParent()
    }

    func add(parent: SKNode) {
        parent.addChild(node)
    }

    var alive: Bool {
        return age <= maxAge
    }
}

enum BoomColor {
    case red, blue
}

class Boom: Particle {
    private let node: SKShapeNode
    static let speeds = 0...6.0
    private var emitterColor: BoomColor
    var xSpeed: Double
    var ySpeed: Double
    private let maxAge: Int
    private var age: Int
    private(set) var size: Double

    init(coordinate: Coordinate, color: BoomColor, xSpeed: Double, ySpeed: Double, age: Int, size: Double, maxAge: Int) {
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

    convenience init(coordinate: Coordinate, color: BoomColor, xSpeed: Double, ySpeed: Double) {
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

    convenience init(coordinate: Coordinate, color: BoomColor, size: Double, age: Int, maxAge: Int) {
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
        if age > maxAge {
            decrease(by: 0.5)
        }
    }

    func remove() {
        node.removeFromParent()
    }

    func add(parent: SKNode) {
        parent.addChild(node)
    }

    var alive: Bool {
        return age <= maxAge && size >= 0
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

    private func decrease(by: Double) {
        size -= by
        node.run(SKAction.scale(by: by, duration: 0))
    }
}

class ParticleEmitter {
    let node: SKNode
    private var particles = [Particle]()

    init() {
        node = SKScene(size: .init(width: Screen.size, height: Screen.size))
    }

    func emitHitSparks(coordinate: Coordinate) {
        for _ in 0..<2 {
            let spark = Spark(
                coordinate: coordinate,
                xSpeed: Double.random(in: 0..<20) - 10,
                ySpeed: Double.random(in: Spark.speeds)
            )
            particles.append(spark)
            spark.add(parent: node)
        }
    }

    func emitBoomSparks(coordinate: Coordinate) {
        for _ in 0..<30 {
            let spark = Spark(coordinate: coordinate)
            particles.append(spark)
            spark.add(parent: node)
        }
    }

    func emitLargeWave(coordinate: Coordinate) {
        let wave = LargeWave(coordinate: coordinate)
        particles.append(wave)
        wave.add(parent: node)
    }

    func emitWave(coordinate: Coordinate) {
        let wave = Wave(coordinate: coordinate)
        particles.append(wave)
        wave.add(parent: node)
    }

    func emitBoom(coordinate: Coordinate, color: BoomColor) {
        for _ in 0..<30 {
            let particle = Boom(
                coordinate: coordinate.moveToSpriteCenter(),
                color: color,
                xSpeed: Double.random(in: Boom.speeds) - Boom.speeds.upperBound/2,
                ySpeed: Double.random(in: Boom.speeds) - Boom.speeds.upperBound/2
            )
            particles.append(particle)
            particle.add(parent: node)
        }
        let particle = Boom(
            coordinate: coordinate,
            color: color,
            size: 8,
            age: 0,
            maxAge: 5
        )
        particles.append(particle)
        particle.add(parent: node)
    }

    func update() {
        for (index, particle) in particles.enumerated().reversed() {
            particle.update()
            if !particle.alive {
                particle.remove()
                particles.remove(at: index)
            }
        }
    }
}
