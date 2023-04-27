import SpriteKit

struct Lives: Drawable {
    private var coordinate: Coordinate = Coordinate(x: 2, y: 2)
    private var node: SKNode!
    static let total = 4
    var lives = 4

    init() {
        node = SKNode()
        node.position = coordinate.toPosition()
        drawLives()
    }

    func add(parent: SKNode) {
        parent.addChild(node)
    }

    var position: CGPoint {
        return node.position
    }

    mutating func substractLife() {
        lives -= 1
        node.removeAllChildren()
        drawLives()
    }

    private func drawLives() {
        for index in 0..<Lives.total {
            let lifeAvailable = SKSpriteNode(imageNamed: "life_0")
            lifeAvailable.zPosition = Layers.interface.rawValue
            let lifeUnavailable = SKSpriteNode(imageNamed: "life_1")
            lifeUnavailable.zPosition = Layers.interface.rawValue
            if index < lives {
                Screen.setup(sprite: lifeAvailable)
                lifeAvailable.position = CGPoint(x: index * (Sprite.size + 1), y: 0)
                node.addChild(lifeAvailable)
            } else {
                Screen.setup(sprite: lifeUnavailable)
                lifeUnavailable.position = CGPoint(x: index * (Sprite.size + 1), y: 0)
                node.addChild(lifeUnavailable)
            }
        }
    }
}

class Score: Drawable, Pixelatable {
    private var score = 0
    private var coordinate: Coordinate = Coordinate(x: 64, y: 6)
    private var node: SKNode!
    private let scoreDisplay: Text

    init() {
        node = SKNode()
        node.zPosition = Layers.interface.rawValue
        scoreDisplay = Text(
            text: "score:\(score)",
            color: Color.lightBlue,
            coordinate: coordinate
        )
        scoreDisplay.add(parent: node)
    }

    func add(parent: SKNode) {
        parent.addChild(node)
    }

    var position: CGPoint {
        return node.position
    }

    func pixelate(using view: SKView) {
        scoreDisplay.pixelate(using: view)
    }

    func update() {
        scoreDisplay.text = "score:\(score)"
    }

    func increment() {
        score += 1
    }
}
