import SpriteKit

class WaveText {
    private(set) var node: SKNode!
    private var text: Text!
    private static var maxAge = 80
    private var age = 0
    private let wave: Int
    private var completion: () -> Void

    init(wave: Int, completion: @escaping () -> Void) {
        self.wave = wave
        self.completion = completion
        node = SKScene(size: .init(width: Screen.size, height: Screen.size))
        text = Text(
            text: "wave \(self.wave)",
            color: Color.darkGrey,
            coordinate: Coordinate(x: 64, y: 32)
        )
        node.addChild(text.node)
    }

    func update() {
        guard !node.isHidden else { return }
        text.blink()
        age += 1
        if age > WaveText.maxAge {
            completion()
            node.isHidden = true
        }
    }
}
