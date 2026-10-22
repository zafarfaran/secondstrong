import Testing
import SSCore
@testable import SSOnboarding

@Suite struct PenPlannerTests {
    private func lastPoint(_ stroke: PenPlanner.Stroke) -> Point? {
        switch stroke.segments.last {
        case .line(let p), .move(let p), .cubic(_, _, let p): p
        default: nil
        }
    }

    @Test func straightNodeDrawsALineAndKeepsTheHeading() {
        var pen = PenPlanner(width: 390)
        let stroke = pen.flow([.line(14, 100)])
        #expect(stroke.segments == [.move(Point(14, -12)), .line(Point(14, 100))])
        #expect(pen.position == Point(14, 100))
        #expect(pen.direction == Point(0, 1))
    }

    @Test func curveControlPointsStayOnThePage() {
        var pen = PenPlanner(width: 100)
        let stroke = pen.flow([.curve(500, 300, dx: 1, dy: 0)])
        guard case .cubic(let c1, let c2, _) = stroke.segments[1] else {
            Issue.record("expected a cubic")
            return
        }
        #expect((8...92).contains(c1.x) && (8...92).contains(c2.x))
    }

    @Test func drawingTimeIsClamped() {
        var pen = PenPlanner(width: 390)
        #expect(pen.flow([.line(14, -10)]).duration == 0.38)
        #expect(pen.flow([.line(14, 5000)]).duration == 1.8)
    }

    @Test func ringEndsAtTheTopFacingItsTravelDirection() {
        var pen = PenPlanner(width: 390)
        let target = Rect(x: 200, y: 300, width: 60, height: 40)
        let stroke = pen.ring(around: target, pad: 6)
        #expect(pen.position == Point(230, 300 + 20 - 26))
        #expect(pen.direction == Point(1, 0))
        #expect(pen.onRing)
        let end = lastPoint(stroke)
        #expect(end.map { abs($0.x - 230) < 0.01 && abs($0.y - 294) < 0.01 } == true)
    }

    @Test func ringCircumferenceMatchesTheEllipse() {
        var pen = PenPlanner(width: 390)
        _ = pen.flow([.line(100, 94)], end: Point(100, 94), endDirection: Point(1, 0))
        let stroke = pen.ring(around: Rect(x: 100, y: 100, width: 40, height: 40), pad: 6)
        let circle = 2 * Double.pi * 26
        #expect(stroke.segments.length > circle)
        #expect(stroke.segments.length < circle + 40)
    }

    @Test func leavingAnElementGoesViaTheRightMarginWhenHeadingRight() {
        var pen = PenPlanner(width: 390)
        _ = pen.ring(around: Rect(x: 100, y: 100, width: 40, height: 40), pad: 6)
        let stroke = pen.toMargin(y: 500)
        #expect(stroke.segments.contains { if case .cubic(_, _, let p) = $0 { p == Point(372, 454) } else { false } })
        #expect(pen.position == Point(14, 514))
        #expect(!pen.onRing)
    }

    @Test func underlineSwingsInFromTheMarginWhenFarAbove() {
        var pen = PenPlanner(width: 390)
        let title = Rect(x: 34, y: 200, width: 200, height: 40)
        let stroke = pen.underline(title)
        #expect(stroke.segments.contains { if case .cubic(_, _, let p) = $0 { p == Point(14, 166) } else { false } })
        #expect(pen.position == Point(240, 245))
    }

    @Test func restoreRewindsThePen() {
        var pen = PenPlanner(width: 390)
        let before = pen.snapshot
        _ = pen.flow([.line(200, 200)])
        pen.restore(before)
        #expect(pen.position == Point(14, -12))
    }
}
