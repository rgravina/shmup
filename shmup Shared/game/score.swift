import SpriteKit

struct Lives {
    private(set) var coordinate: Coordinate = Coordinate(x: 2, y: 2)
    private(set) var node: SKNode!
    static let total = 4
    var lives = 4

    init() {
        node = SKNode()
        node.position = coordinate.toPosition()
        drawLives()
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

struct Score {
    private var score = 0
    private(set) var coordinate: Coordinate = Coordinate(x: 42, y: 9)
    private(set) var node: SKNode!
    private var display: SKLabelNode!

    init() {
        node = SKNode()
        node.position = coordinate.toPosition()
        node.zPosition = Layers.interface.rawValue
        display = SKLabelNode(fontNamed: "PICO-8")
        display.horizontalAlignmentMode = .left
        display.fontSize = 6
        display.fontColor = Color.lightBlue
        node.addChild(display)
    }

    func update() {
        display.text = "score:\(score)"
    }

    mutating func increment() {
        score += 1
    }
}
