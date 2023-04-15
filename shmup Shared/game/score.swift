import SpriteKit

struct Lives {
    private(set) var coordinate: Coordinate = Coordinate(x: 2, y: 2)
    private(set) var node: SKNode!
    static let total = 4
    let lives = 1

    init() {
        node = SKNode()
        node.position = coordinate.toPosition()
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
    private var score = 10000
    private(set) var coordinate: Coordinate = Coordinate(x: 64, y: 9)
    private(set) var node: SKNode!

    init() {
        node = SKNode()
        node.position = coordinate.toPosition()
        node.zPosition = Layers.interface.rawValue
        drawScore()
    }

    private func drawScore() {
        let display = SKLabelNode(fontNamed: "PICO-8")
        display.fontSize = 6
        display.fontColor = Color.lightBlue
        display.text = "score:\(score)"
        node.addChild(display)
    }
}
