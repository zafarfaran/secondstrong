import SwiftUI

/// A measuring tape you drag under a fixed pen marker. Reports a value only once it has been moved,
/// so a starting position is never mistaken for an answer.
public struct RulerPicker: View {
    public struct Spec: Equatable, Sendable {
        public let range: ClosedRange<Double>
        public let step: Double
        public let ticksPerMajor: Int
        public let label: @Sendable (Double) -> String

        public init(range: ClosedRange<Double>, step: Double, ticksPerMajor: Int, label: @escaping @Sendable (Double) -> String) {
            self.range = range
            self.step = step
            self.ticksPerMajor = ticksPerMajor
            self.label = label
        }

        public static func == (a: Spec, b: Spec) -> Bool { a.range == b.range && a.step == b.step && a.ticksPerMajor == b.ticksPerMajor }

        var count: Int { Int(((range.upperBound - range.lowerBound) / step).rounded()) }
        func value(at index: Int) -> Double { range.lowerBound + Double(index) * step }
        func index(of value: Double) -> Int { min(max(Int(((value - range.lowerBound) / step).rounded()), 0), count) }
    }

    let spec: Spec
    let start: Double
    let onChange: (Double) -> Void
    @State private var position: Int?
    @State private var ready = false

    private let tickWidth: CGFloat = 10

    public init(spec: Spec, start: Double, onChange: @escaping (Double) -> Void) {
        self.spec = spec
        self.start = start
        self.onChange = onChange
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(0...spec.count, id: \.self) { i in tick(i).id(i) }
                }
                .scrollTargetLayout()
                .frame(height: proxy.size.height)
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $position, anchor: .center)
            .contentMargins(.horizontal, max(0, proxy.size.width / 2 - tickWidth / 2), for: .scrollContent)
            .mask(LinearGradient(stops: [
                .init(color: .clear, location: 0), .init(color: .black, location: 0.18),
                .init(color: .black, location: 0.82), .init(color: .clear, location: 1),
            ], startPoint: .leading, endPoint: .trailing))
            .overlay {
                Capsule().fill(Palette.pen).frame(width: 3, height: proxy.size.height - 26).offset(y: -6).allowsHitTesting(false)
            }
        }
        .frame(height: 72)
        .sensoryFeedback(.selection, trigger: position)
        .task {
            try? await Task.sleep(for: .milliseconds(150))
            position = spec.index(of: start)
            try? await Task.sleep(for: .milliseconds(300))
            ready = true
        }
        .onChange(of: position) { _, new in
            guard ready, let new else { return }
            onChange(spec.value(at: new))
        }
    }

    private func tick(_ i: Int) -> some View {
        let major = i % spec.ticksPerMajor == 0
        let mid = !major && spec.ticksPerMajor % 2 == 0 && i % (spec.ticksPerMajor / 2) == 0
        return ZStack(alignment: .bottom) {
            Rectangle()
                .fill(major ? Palette.ink : Palette.ink.opacity(mid ? 0.6 : 0.33))
                .frame(width: 1.5, height: major ? 42 : (mid ? 30 : 20))
                .padding(.bottom, 18)
            if major {
                Text(spec.label(spec.value(at: i)))
                    .font(SSFont.display(11, weight: 600))
                    .foregroundStyle(Palette.ink2)
                    .fixedSize()
                    .frame(width: tickWidth)
            }
        }
        .frame(width: tickWidth, alignment: .bottom)
    }
}
