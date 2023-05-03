import SpriteKit

protocol Collidable {
    var position: CGPoint { get }
    var collisionBoxWidth: Int { get }
}

struct Box {
    static let padding: CGFloat = 2
    let left: CGFloat
    let right: CGFloat
    let top: CGFloat
    let bottom: CGFloat
}

struct Collision {
    static func collides(a: Collidable, b: Collidable) -> Bool {
        let aBox = Collision.box(a)
        let bBox = Collision.box(b)
        return !(aBox.right < bBox.left ||
                 aBox.left > bBox.right ||
                 aBox.top < bBox.bottom ||
                 aBox.bottom > bBox.top)
    }

    private static func box(_ sprite: Collidable) -> Box {
        let position = sprite.position
        return Box(left: position.x + Box.padding,
                   right: position.x + (CGFloat(sprite.collisionBoxWidth) - Box.padding),
                   top: position.y - Box.padding,
                   bottom: position.y - (CGFloat(sprite.collisionBoxWidth) - Box.padding)
        )
    }
}
