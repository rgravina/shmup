import SpriteKit

struct Box {
    static let padding: CGFloat = 2
    let left: CGFloat
    let right: CGFloat
    let top: CGFloat
    let bottom: CGFloat
}

struct Collision {
    static func collides(a: Drawable, b: Drawable) -> Bool {
        let aBox = Collision.box(a.position)
        let bBox = Collision.box(b.position)
        return !(aBox.right < bBox.left ||
                 aBox.left > bBox.right ||
                 aBox.top < bBox.bottom ||
                 aBox.bottom > bBox.top)
    }

    private static func box(_ position: CGPoint) -> Box {
        return Box(left: position.x + Box.padding,
                   right: position.x + (CGFloat(Sprite.size) - Box.padding),
                   top: position.y - Box.padding,
                   bottom: position.y - (CGFloat(Sprite.size) - Box.padding)
        )
    }
}
