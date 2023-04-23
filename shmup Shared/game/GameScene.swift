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
        addChild(starField.node)
        addChild(player.node)
        addChild(plasmaBalls.node)
        addChild(emitter.node)
        addChild(enemies.node)
        addChild(lives.node)
        addChild(score.node)
    }

    override func update(_ currentTime: TimeInterval) {
        plasmaBalls.update(player: player, enemies: enemies) { [self] (enemy: Enemy, ball: PlasmaBall) in
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
        player.update()
        emitter.update()
        enemies.update(
            player: player,
            onCollision: {
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
            },
            onNewWave: {
                if enemies.wave > 4, let skView = view {
                    let scene = WinScene.newGameScene()
                    skView.presentScene(scene)
                    skView.ignoresSiblingOrder = true
                    skView.showsFPS = true
                    skView.showsNodeCount = true
                }
            }
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
