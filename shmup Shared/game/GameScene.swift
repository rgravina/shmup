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

    override func didMove(to view: SKView) {
        view.preferredFramesPerSecond = Screen.framesPerSecond
        player = Player(soundPlayer: soundPlayer)
        starField.add(parent: self)
        player.add(parent: self)
        plasmaBalls.add(parent: self)
        addChild(emitter.node)
        enemies.add(parent: self)
        enemies.pixelate(using: view)
        lives.add(parent: self)
        score.add(parent: self)
        score.pixelate(using: view)
    }

    private func onPlayerEmemyCollision() {
        lives.substractLife()
        player.hit()
        run(soundPlayer.collision)
        emitter.emitBoom(
            coordinate: player.coordinate,
            color: BoomColor.blue
        )
        emitter.emitLargeWave(coordinate: player.coordinate)
        emitter.emitBoomSparks(coordinate: player.coordinate)
        if lives.lives == 0, let skView = view {
            let scene = GameOverScene.newGameScene()
            skView.presentScene(scene)
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
    }

    private func onNewEnemyWave() {
        if enemies.wave > 4, let skView = view {
            let scene = WinScene.newGameScene()
            skView.presentScene(scene)
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
    }

    private func onBallEnemyCollision(enemy: Enemy, ball: PlasmaBall) {
        if enemy.destroyed {
            run(soundPlayer.enemyDestroy)
            score.increment()
            emitter.emitBoom(
                coordinate: enemy.coordinate,
                color: BoomColor.red
            )
            emitter.emitLargeWave(coordinate: ball.coordinate)
            emitter.emitBoomSparks(coordinate: ball.coordinate)
        } else {
            run(soundPlayer.enemyHit)
            emitter.emitWave(coordinate: ball.coordinate)
            emitter.emitHitSparks(coordinate: ball.coordinate)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        plasmaBalls.update(
            player: player,
            enemies: enemies,
            onCollision: onBallEnemyCollision
        )
        player.update()
        emitter.update()
        enemies.update(
            player: player,
            onCollision: onPlayerEmemyCollision,
            onNewWave: onNewEnemyWave
        )
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
