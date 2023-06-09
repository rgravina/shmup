import SpriteKit

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
        guard let view = view else { return }

        view.preferredFramesPerSecond = Screen.framesPerSecond
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
        intro1.add(parent: self)
        intro1.pixelate(using: view)
        intro2.add(parent: self)
        intro2.pixelate(using: view)
        intro3.add(parent: self)
        intro3.pixelate(using: view)
        pressKey.add(parent: self)
        pressKey.pixelate(using: view)
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
