import SpriteKit

class WinScene: SKScene {
    private var screen = Screen()
    private var pressKey: Text!

    class func newGameScene() -> WinScene {
        let scene = WinScene(size: CGSize(width: Screen.size, height: Screen.size))
        scene.anchorPoint = .init(x: 0, y: 0)
        scene.scaleMode = .aspectFill
        scene.screen.use(scene: scene)
        scene.backgroundColor = Color.black
        return scene
    }

    func setUpScene() {
        view?.preferredFramesPerSecond = Screen.framesPerSecond
        let intro = Text(
            text: "you win",
            color: Color.darkGreen,
            coordinate: Coordinate(x: 64, y: 40)
        )
        pressKey = Text(
            text: "press O to continue",
            color: Color.lightGrey,
            coordinate: Coordinate(x: 64, y: 96)
        )
        addChild(intro.node)
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
