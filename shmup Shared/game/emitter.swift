import SpriteKit

class Spark {
    private(set) var node: SKSpriteNode!
    static let speeds = 0...6.0
    var xSpeed: Double
    var ySpeed: Double
    let maxAge: Int
    var age: Int

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
}

class LargeWave {
    private(set) var node: SKShapeNode!
    let startRadius: CGFloat = 2
    let maxAge: Int = 5
    var age: Int = 0

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
}

class Wave {
    private(set) var node: SKSpriteNode!
    let maxAge: Int = 10
    var age: Int = 0

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
}

enum BoomColor {
    case red, blue
}

class Boom {
    private(set) var node: SKShapeNode!
    static let speeds = 0...6.0
    private var emitterColor: BoomColor
    var xSpeed: Double
    var ySpeed: Double
    let maxAge: Int
    var age: Int
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
    private(set) var node: SKNode!
    private var booms = [Boom]()
    private var waves = [Wave]()
    private var largeWaves = [LargeWave]()
    private var sparks = [Spark]()

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
            sparks.append(spark)
            node.addChild(spark.node)
        }
    }

    func emitLotsOfSparks(coordinate: Coordinate) {
        for _ in 0..<30 {
            let spark = Spark(coordinate: coordinate)
            sparks.append(spark)
            node.addChild(spark.node)
        }
    }

    func emitLargeWave(coordinate: Coordinate) {
        let wave = LargeWave(coordinate: coordinate)
        largeWaves.append(wave)
        node.addChild(wave.node)
    }

    func emitWave(coordinate: Coordinate) {
        let wave = Wave(coordinate: coordinate)
        waves.append(wave)
        node.addChild(wave.node)
    }

    func emitBoom(coordinate: Coordinate, color: BoomColor) {
        for _ in 0..<30 {
            let particle = Boom(
                coordinate: coordinate.moveToSpriteCenter(),
                color: color,
                xSpeed: Double.random(in: Boom.speeds) - Boom.speeds.upperBound/2,
                ySpeed: Double.random(in: Boom.speeds) - Boom.speeds.upperBound/2
            )
            booms.append(particle)
            node.addChild(particle.node)
        }
        let particle = Boom(
            coordinate: coordinate,
            color: color,
            size: 8,
            age: 0,
            maxAge: 5
        )
        booms.append(particle)
        node.addChild(particle.node)
    }

    func update() {
        for (index, spark) in sparks.enumerated().reversed() {
            spark.update()
            if spark.age > spark.maxAge {
                spark.node.removeFromParent()
                sparks.remove(at: index)
            }
        }
        for (index, wave) in waves.enumerated().reversed() {
            wave.update()
            if wave.age > wave.maxAge {
                wave.node.removeFromParent()
                waves.remove(at: index)
            }
        }
        for (index, wave) in largeWaves.enumerated().reversed() {
            wave.update()
            if wave.age > wave.maxAge {
                wave.node.removeFromParent()
                largeWaves.remove(at: index)
            }
        }
        for (index, particle) in booms.enumerated().reversed() {
            particle.update()
            if particle.age > particle.maxAge {
                particle.decrease(by: 0.5)
                if particle.size < 0 {
                    particle.node.removeFromParent()
                    booms.remove(at: index)
                }
            }
        }
    }
}
