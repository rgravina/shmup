import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = StartScene.newGameScene()

        let skView = self.view as? SKView
        if let skView = skView {
            skView.presentScene(scene)
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
    }
}
