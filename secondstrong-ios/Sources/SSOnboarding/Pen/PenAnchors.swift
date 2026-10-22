import SwiftUI
import SSCore

/// Elements the pen needs to find: it underlines, rings and routes around them.
enum PenAnchor: Hashable {
    case title(Int), next(Int)
    case sub, hero, coachShow, nameField
    case stage(Stage), goal(Goal)
    case agree, words, birth, body
    case safety(SafetyFlag), experience(Experience), equipment(Equipment)
    case week, day(Weekday)
    case pnum, bar, wk2, dot(Weekday), note, start
}

enum PenSpace {
    static let name = "doc"
}

struct PenFrames: PreferenceKey {
    static let defaultValue: [PenAnchor: Rect] = [:]

    static func reduce(value: inout [PenAnchor: Rect], nextValue: () -> [PenAnchor: Rect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

extension View {
    /// Reports this view's frame, in document coordinates, under `anchor`.
    func penAnchor(_ anchor: PenAnchor) -> some View {
        background(GeometryReader { proxy in
            let f = proxy.frame(in: .named(PenSpace.name))
            Color.clear.preference(
                key: PenFrames.self,
                value: [anchor: Rect(x: f.minX, y: f.minY, width: f.width, height: f.height)])
        })
    }
}
