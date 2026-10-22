import Foundation
import SSCore

/// Plans the route of the single onboarding line. Port of the prototype's pen
/// (design/onboarding/line_part.js): tangent-matched curves, true-ellipse rings,
/// and changes of row that swing through the margins so the line never crosses text.
struct PenPlanner {
    struct Node {
        var point: Point
        /// Direction the line should be travelling on arrival. Nil means reach it in a straight line.
        var direction: Point?
        var tension = 0.42

        static func curve(_ x: Double, _ y: Double, dx: Double, dy: Double, tension: Double = 0.42) -> Node {
            Node(point: Point(x, y), direction: Point(dx, dy), tension: tension)
        }

        static func line(_ x: Double, _ y: Double) -> Node {
            Node(point: Point(x, y), direction: nil)
        }
    }

    /// Seconds. Drawing speed is one second per 1000 points of line, clamped.
    struct Pace {
        var minimum = 0.38
        var maximum = 1.8
        var speed = 1.0
    }

    struct Stroke {
        let segments: [PathSegment]
        let duration: Double
    }

    struct Snapshot {
        let position: Point
        let direction: Point
    }

    let width: Double
    let gutter = 14.0
    var rightMargin: Double { width - 18 }

    private(set) var position = Point(14, -12)
    private(set) var direction = Point(0, 1)
    private(set) var onRing = false

    init(width: Double) { self.width = width }

    var snapshot: Snapshot { Snapshot(position: position, direction: direction) }

    mutating func restore(_ s: Snapshot) {
        position = s.position
        direction = s.direction
        onRing = false
    }

    mutating func leaveRing() { onRing = false }

    /// Draws through `nodes`, then appends `extra` (raw SVG path data continuing from the last node).
    mutating func flow(
        _ nodes: [Node], extra: String = "", end: Point? = nil, endDirection: Point? = nil, pace: Pace = Pace()
    ) -> Stroke {
        var data = "M\(f(position.x)) \(f(position.y))"
        var from = position
        var heading = direction
        for node in nodes {
            if let arrival = node.direction {
                let k = node.tension * (node.point - from).length
                let c1x = min(width - 8, max(8, from.x + heading.x * k))
                let c2x = min(width - 8, max(8, node.point.x - arrival.x * k))
                data += " C\(f(c1x)) \(f(from.y + heading.y * k)) \(f(c2x)) \(f(node.point.y - arrival.y * k))"
                data += " \(f(node.point.x)) \(f(node.point.y))"
                heading = arrival
            } else {
                data += " L\(f(node.point.x)) \(f(node.point.y))"
                heading = (node.point - from).normalized
            }
            from = node.point
        }
        let segments = SVGPath.parse(data + extra)
        position = end ?? from
        direction = endDirection ?? heading
        return Stroke(segments: segments, duration: duration(of: segments, pace))
    }

    /// Travel to the top of an element, circle it as a true ellipse, leave along the same tangent.
    mutating func ring(around r: Rect, pad: Double) -> Stroke {
        let rx = r.width / 2 + pad
        let ry = r.height / 2 + pad
        let cx = r.midX
        let top = r.midY - ry
        let head: Point
        var nodes: [Node]
        if onRing && abs(position.y - top) < 2 && cx > position.x {
            head = Point(1, 0)
            nodes = [.line(cx, top)]
        } else if onRing && top > position.y + 20 {
            head = Point(-1, 0)
            nodes = [.curve(rightMargin, (position.y + top) / 2, dx: 0, dy: 1), .curve(cx, top, dx: head.x, dy: head.y)]
        } else {
            head = cx < position.x - 10 ? Point(-1, 0) : Point(1, 0)
            nodes = [.curve(cx, top, dx: head.x, dy: head.y, tension: 0.5)]
        }
        let sweep = head.x > 0 ? 1 : 0
        let arcs = " A\(f(rx)) \(f(ry)) 0 0 \(sweep) \(f(cx)) \(f(r.midY + ry))"
            + " A\(f(rx)) \(f(ry)) 0 0 \(sweep) \(f(cx)) \(f(top))"
        onRing = true
        return flow(nodes, extra: arcs, end: Point(cx, top), endDirection: head)
    }

    /// Back to the left margin through the empty space above the button.
    mutating func toMargin(y: Double) -> Stroke {
        onRing = false
        let nodes: [Node] = direction.x > 0.3
            ? [.curve(rightMargin, y - 46, dx: 0, dy: 1), .curve(gutter, y + 14, dx: 0, dy: 1)]
            : [.curve(gutter, min(y, position.y + 50), dx: 0, dy: 1), .line(gutter, y + 14)]
        return flow(nodes)
    }

    /// Down the margin, curve in, and underline the question.
    mutating func underline(_ t: Rect) -> Stroke {
        let y = t.maxY + 5
        var nodes: [Node] = []
        if position.y < t.y - 70 { nodes.append(.curve(gutter, t.y - 34, dx: 0, dy: 1)) }
        nodes.append(.curve(t.x - 4, y, dx: 1, dy: 0))
        nodes.append(.line(t.maxX + 6, y))
        return flow(nodes, pace: Pace(minimum: 0.7))
    }

    private func duration(of segments: [PathSegment], _ pace: Pace) -> Double {
        min(pace.maximum, max(pace.minimum, segments.length / 1000 * pace.speed))
    }

    private func f(_ v: Double) -> String { String(format: "%.1f", v) }
}
