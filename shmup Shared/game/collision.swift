import SpriteKit

struct Box {
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
        return Box(left: point.x,
                   right: point.x + CGFloat(Sprite.size),
                   top: point.y,
                   bottom: point.y - CGFloat(Sprite.size)
        )
    }
}
