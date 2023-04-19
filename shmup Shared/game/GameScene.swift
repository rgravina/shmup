import SpriteKit

class GameScene: SKScene {
    private var player: Player!
    private var plasmaBalls = PlasmaBalls()
    private var enemies = Enemies()
    private var screen = Screen()
    private var lives = Lives()
    private var score = Score()
    private var soundPlayer = SoundPlayer()
    private var starField = StarField()
    private var emitter = ParticleEmitter()

    class func newGameScene() -> GameScene {
        let scene = GameScene(size: CGSize(width: Screen.size, height: Screen.size))
        scene.anchorPoint = .init(x: 0, y: 0)
        scene.scaleMode = .aspectFill
        scene.screen.use(scene: scene)
        scene.backgroundColor = Color.black
        return scene
    }

    func setUpScene() {
        view?.preferredFramesPerSecond = Screen.framesPerSecond
        player = Player(soundPlayer: soundPlayer)
        addChild(starField.node)
        addChild(player.node)
        addChild(plasmaBalls.node)
        addChild(emitter.node)
        addChild(enemies.node)
        addChild(lives.node)
        addChild(score.node)
    }

    override func didMove(to view: SKView) {
        self.setUpScene()
    }

    override func update(_ currentTime: TimeInterval) {
        plasmaBalls.update(player: player, enemies: enemies) { [self] (enemyDestroyed: Bool, enemy: Enemy) in
            if enemyDestroyed {
                run(soundPlayer.enemyDestroy)
                score.increment()
                emitter.emit(coordinate: enemy.coordinate)
            } else {
                run(soundPlayer.enemyHit)
            }
        }
        player.update()
        emitter.update()
        enemies.update(player: player) { [self] in
            lives.substractLife()
            player.hit()
            run(soundPlayer.collision)
            if lives.lives == 0, let skView = view {
                let scene = GameOverScene.newGameScene()
                skView.presentScene(scene)
                skView.ignoresSiblingOrder = true
                skView.showsFPS = true
                skView.showsNodeCount = true
            }
        }
        score.update()
        starField.update()
    }

    override func keyUp(with event: NSEvent) {
        let keyCode = KeyCodes(rawValue: event.keyCode)
        if keyCode?.toDirection() == player.direction {
            player.point(direction: .none)
        }
        if keyCode == KeyCodes.zKey {
            player.endFiring()
        }
    }

    override func keyDown(with event: NSEvent) {
        let keyCode = KeyCodes(rawValue: event.keyCode)
        let direction = keyCode?.toDirection() ?? Direction.none
        if direction != .none {
            player.point(direction: direction)
        }
        if keyCode == KeyCodes.zKey {
            player.startFiring()
        }
    }
}
