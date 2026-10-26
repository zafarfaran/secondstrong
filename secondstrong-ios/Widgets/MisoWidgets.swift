import SwiftUI
import WidgetKit
import SSCore
import SSDesign
import SSWidgets

/// The WidgetKit extension: it only reads the snapshot the app shared and draws the SSWidgets views (SS-0030).
/// Not yet run on a device; the views and the snapshot rules are tested in the package.
struct MisoEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct MisoProvider: TimelineProvider {
    private func current(_ date: Date = Date()) -> WidgetSnapshot {
        let hour = Calendar.current.component(.hour, from: date)
        guard var saved = WidgetStore().load() else {
            return WidgetSnapshot(coach: .miso, proteinGrams: 0, proteinTarget: 85, hour: hour, hideLockScreenNumbers: true)
        }
        saved.hour = hour
        return saved
    }

    func placeholder(in context: Context) -> MisoEntry { MisoEntry(date: Date(), snapshot: .init(coach: .miso, proteinGrams: 62, proteinTarget: 85, hour: 9, hideLockScreenNumbers: false)) }

    func getSnapshot(in context: Context, completion: @escaping (MisoEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : MisoEntry(date: Date(), snapshot: current()))
    }

    /// One entry now and one at each hour the pose can change (7 pm evening, 5 am morning); the app also asks for a reload when she logs.
    func getTimeline(in context: Context, completion: @escaping (Timeline<MisoEntry>) -> Void) {
        let calendar = Calendar.current, now = Date()
        let next = [19, 5].compactMap { calendar.nextDate(after: now, matching: DateComponents(hour: $0), matchingPolicy: .nextTime) }.min() ?? now.addingTimeInterval(3600)
        let entries = [MisoEntry(date: now, snapshot: current(now)), MisoEntry(date: next, snapshot: current(next))]
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct MisoHomeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MisoHome", provider: MisoProvider()) { entry in
            Group {
                MisoSizes(entry: entry)
            }
            .containerBackground(Palette.ivory, for: .widget)
        }
        .configurationDisplayName("Miso")
        .description("Your coach and your protein for the day.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

private struct MisoSizes: View {
    @Environment(\.widgetFamily) private var family
    let entry: MisoEntry

    var body: some View {
        switch family {
        case .systemMedium: MisoMediumWidget(entry.snapshot).padding(16)
        default: MisoSmallWidget(entry.snapshot).padding(12)
        }
    }
}

struct MisoLockWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MisoLock", provider: MisoProvider()) { entry in
            LockSizes(entry: entry).containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Miso")
        .description("Your protein on the lock screen. Numbers can be hidden in Privacy and data.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

private struct LockSizes: View {
    @Environment(\.widgetFamily) private var family
    let entry: MisoEntry

    var body: some View {
        switch family {
        case .accessoryRectangular: MisoLockRectangle(entry.snapshot).widgetAccentable()
        default: MisoLockCircle(entry.snapshot).widgetAccentable()
        }
    }
}

@main
struct MisoWidgets: WidgetBundle {
    var body: some Widget {
        MisoHomeWidget()
        MisoLockWidget()
    }
}
