import SpriteKit

class Star {
    private static let slowStarSpeed: Double = 0.6
    private static let normalStarSpeed: Double = 1.8
    private static let fastStarSpeed: Double = 2.5
    static let starSpeeds = 0.2...fastStarSpeed
    private(set) var node: SKSpriteNode!
    var speed: Double

    init(coordinate: Coordinate, speed: Double) {
        self.speed = speed
        switch speed {
        case 0..<Star.slowStarSpeed:
            node = SKSpriteNode(imageNamed: "star_2")
        case Star.slowStarSpeed..<Star.normalStarSpeed:
            node = SKSpriteNode(imageNamed: "star_1")
        default:
            node = SKSpriteNode(imageNamed: "star_0")
        }
        node.position = coordinate.toPosition()
        node.speed = self.speed
        node.zPosition = Layers.background.rawValue
    }

    func update() {
        node.position.y = node.position.y < 0 ? CGFloat(Screen.size) : node.position.y - speed
    }
}

struct StarField {
    private static let totalStars = 100
    private(set) var node: SKNode!
    private var stars = [Star]()

    init() {
        node = SKScene(size: .init(width: Screen.size, height: Screen.size))
        for _ in 0..<StarField.totalStars {
            let star = Star(
                coordinate: Screen.randomCoordinate(),
                speed: Double.random(in: Star.starSpeeds)
            )
            stars.append(star)
            node.addChild(star.node)
        }
    }

    func update() {
        stars.forEach { $0.update() }
    }
}
