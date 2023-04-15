import SpriteKit

struct Text {
    private(set) var node: SKNode!
    private var blinkColors = [
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.darkGrey,
        Color.lightGrey,
        Color.lightGrey,
        Color.white,
        Color.white,
        Color.lightGrey,
        Color.lightGrey
    ]
    private let display = SKLabelNode(fontNamed: "PICO-8")
    var blinkIndex = 0
    var text: String
    var color: NSColor

    init(text: String, color: NSColor, coordinate: Coordinate) {
        self.text = text
        self.color = color
        node = SKNode()
        node.position = coordinate.toPosition()
        node.zPosition = Layers.interface.rawValue
        drawText()
    }

    mutating func blink() {
        blinkIndex = blinkIndex >= blinkColors.count - 1 ? 0 : blinkIndex + 1
        display.fontColor = blinkColors[blinkIndex]
    }

    private func drawText() {
        display.fontSize = 6
        display.fontColor = self.color
        display.text = text
        node.addChild(display)
    }
}

class StartScene: SKScene {
    private var screen = Screen()
    private var pressKey: Text!

    class func newGameScene() -> StartScene {
        let scene = StartScene(size: CGSize(width: Screen.size, height: Screen.size))
        scene.anchorPoint = .init(x: 0, y: 0)
        scene.scaleMode = .aspectFill
        scene.screen.use(scene: scene)
        scene.backgroundColor = Color.black
        return scene
    }

    func setUpScene() {
        view?.preferredFramesPerSecond = Screen.framesPerSecond
        let intro1 = Text(
            text: "spritekit port of",
            color: Color.lightBlue,
            coordinate: Coordinate(x: 64, y: 32)
        )
        let intro2 = Text(
            text: "lazydevs",
            color: Color.lightBlue,
            coordinate: Coordinate(x: 64, y: 40)
        )
        let intro3 = Text(
            text: "pico8 shmup tutorial",
            color: Color.lightBlue,
            coordinate: Coordinate(x: 64, y: 48)
        )
        pressKey = Text(
            text: "press O to start",
            color: Color.lightGrey,
            coordinate: Coordinate(x: 64, y: 96)
        )
        addChild(intro1.node)
        addChild(intro2.node)
        addChild(intro3.node)
        addChild(pressKey.node)
    }

    override func didMove(to view: SKView) {
        self.setUpScene()
    }

    override func update(_ currentTime: TimeInterval) {
        pressKey.blink()
    }

    override func keyDown(with event: NSEvent) {
        let keyCode = KeyCodes(rawValue: event.keyCode)
        guard keyCode == KeyCodes.zKey else {
            return
        }
        if let skView = view {
            let scene = GameScene.newGameScene()
            skView.presentScene(scene)
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
    }
}
