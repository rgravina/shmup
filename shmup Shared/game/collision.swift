import SpriteKit

struct Box {
    static let padding: CGFloat = 2
    let left: CGFloat
    let right: CGFloat
    let top: CGFloat
    let bottom: CGFloat
}

struct Collision {
    static func collides(a: SKNode, b: SKNode) -> Bool {
        let aBox = Collision.box(a.position)
        let bBox = Collision.box(b.position)
        return !(aBox.right < bBox.left ||
                 aBox.left > bBox.right ||
                 aBox.top < bBox.bottom ||
                 aBox.bottom > bBox.top)
    }

    private static func box(_ point: CGPoint) -> Box {
        return Box(left: point.x + Box.padding,
                   right: point.x + (CGFloat(Sprite.size) - Box.padding),
                   top: point.y - Box.padding,
                   bottom: point.y - (CGFloat(Sprite.size) + Box.padding)
        )
    }
}
