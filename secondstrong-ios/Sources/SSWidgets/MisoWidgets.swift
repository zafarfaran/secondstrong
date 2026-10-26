import SwiftUI
import SSCore
import SSDesign

/// The widget faces, as plain SwiftUI so they can be drawn and checked off the phone. The WidgetKit extension in Widgets/ only
/// wraps these (SS-0030). Protein only, never weight or calories; the coach is a still picture because widgets cannot play video.

/// Small home widget: the coach's face inside a protein ring.
public struct MisoSmallWidget: View {
    let snapshot: WidgetSnapshot

    public init(_ snapshot: WidgetSnapshot) { self.snapshot = snapshot }

    public var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().stroke(Palette.ink.opacity(0.10), lineWidth: 6)
                Circle().trim(from: 0, to: snapshot.fraction).stroke(Palette.ink, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                PaperArt.still(snapshot.stillName).resizable().scaledToFit().scaleEffect(1.5).padding(10).clipShape(Circle().inset(by: 9))
            }
            .frame(width: 112, height: 112)
            Text("\(snapshot.proteinGrams) of \(snapshot.proteinTarget)g").font(SSFont.display(12, weight: 700)).foregroundStyle(Palette.ink)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(snapshot.coach.name). Protein \(snapshot.proteinGrams) of \(snapshot.proteinTarget) grams.")
    }
}

/// Medium home widget: the coach with a speech note, and protein.
public struct MisoMediumWidget: View {
    let snapshot: WidgetSnapshot

    public init(_ snapshot: WidgetSnapshot) { self.snapshot = snapshot }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PaperArt.still(snapshot.stillName).resizable().scaledToFit().frame(width: 128, height: 128).offset(x: 6, y: 8)
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(snapshot.line, id: \.self) { Text($0).font(SSFont.hand(17)).foregroundStyle(Palette.ink) }
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Palette.card, in: UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 4, bottomTrailingRadius: 16, topTrailingRadius: 16))
                VStack(alignment: .leading, spacing: 5) {
                    MetaLabel("Protein")
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text("\(snapshot.proteinGrams)").font(SSFont.display(30)).tracking(-1.4).foregroundStyle(Palette.ink)
                        Text("/ \(snapshot.proteinTarget)g").font(SSFont.display(12, weight: 600)).foregroundStyle(Palette.ink2)
                    }
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Palette.ink.opacity(0.10))
                            Capsule().fill(Palette.ink).frame(width: proxy.size.width * snapshot.fraction)
                        }
                    }
                    .frame(width: 120, height: 4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(snapshot.coach.name). \(snapshot.line.joined(separator: " ")) Protein \(snapshot.proteinGrams) of \(snapshot.proteinTarget) grams.")
    }
}

/// Lock screen circle: the face inside the ring. With numbers hidden there is no ring, only the face.
public struct MisoLockCircle: View {
    let snapshot: WidgetSnapshot

    public init(_ snapshot: WidgetSnapshot) { self.snapshot = snapshot }

    public var body: some View {
        ZStack {
            if let ring = snapshot.lockScreenRing {
                Circle().stroke(.primary.opacity(0.25), lineWidth: 4)
                Circle().trim(from: 0, to: ring).stroke(.primary, style: StrokeStyle(lineWidth: 4, lineCap: .round)).rotationEffect(.degrees(-90))
            }
            PaperArt.still(snapshot.stillName).resizable().scaledToFit().scaleEffect(1.5).padding(snapshot.lockScreenRing == nil ? 4 : 9)
                .clipShape(Circle().inset(by: snapshot.lockScreenRing == nil ? 2 : 6))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(snapshot.lockScreenProtein.map { "Protein \($0) grams" } ?? snapshot.coach.name)
    }
}

/// Lock screen rectangle: protein as a bar. With numbers hidden it only says whose it is.
public struct MisoLockRectangle: View {
    let snapshot: WidgetSnapshot

    public init(_ snapshot: WidgetSnapshot) { self.snapshot = snapshot }

    public var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            if let protein = snapshot.lockScreenProtein, let ring = snapshot.lockScreenRing {
                Text("PROTEIN").font(SSFont.display(11, weight: 700)).tracking(0.9).opacity(0.8)
                Text(protein).font(SSFont.display(20)).tracking(-0.6)
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.primary.opacity(0.25))
                        Capsule().fill(.primary).frame(width: proxy.size.width * ring)
                    }
                }
                .frame(height: 4)
            } else {
                Text(snapshot.coach.name.uppercased()).font(SSFont.display(11, weight: 700)).tracking(0.9).opacity(0.8)
                Text("Open to see your day").font(SSFont.display(15, weight: 600))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
