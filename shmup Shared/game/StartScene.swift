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
        let sheet = SpriteSheet(
            imageNamed: "enemysprites",
            rows: 7,
            cols: 16
        )
        let sprite1 = sheet.sprite(row: 3, col: 8)
        sprite1.position = Coordinate(x: 56, y: 64).toPosition()
        let sprite2 = sheet.sprite(row: 1, col: 4)
        sprite2.position = Coordinate(x: 64, y: 64).toPosition()
        let sprite3 = sheet.sprite(row: 5, col: 0, size: 2)
        sprite3.position = Coordinate(x: 56, y: 80).toPosition()
        addChild(intro1.node)
        addChild(intro2.node)
        addChild(intro3.node)
        addChild(pressKey.node)
        addChild(sprite1)
        addChild(sprite2)
        addChild(sprite3)
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
