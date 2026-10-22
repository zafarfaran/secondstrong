import SwiftUI
import SSCore

public extension Coach {
    /// The coach's own picture, idle pose, transparent background.
    @MainActor var image: Image { BundledImage.load("coach-\(rawValue)") }

    /// Body outline (and any back parts) on the 200 x 200 mascot grid, as SVG path data.
    var outlinePaths: [String] {
        let outline = CoachOutlines.outline(for: self)
        return [outline.body] + outline.extras
    }
}

/// The paper look from design/onboarding/paper: torn-paper scenes behind the pages, a paper hill for each
/// coach, paper moons for the stages, and small cut-outs for goals and screens.
public enum PaperArt {
    public enum Scene: String, Sendable {
        case welcome, days, plan

        /// Height over width of the picture.
        public var aspect: CGFloat { self == .welcome ? 1.5 : 2.0 / 3.0 }
    }

    @MainActor public static func scene(_ scene: Scene, dark: Bool) -> Image {
        BundledImage.load("paper-\(scene.rawValue)" + (dark ? "-dark" : ""), ext: "jpg")
    }

    /// The small paper hill every coach stands on.
    @MainActor public static var plinth: Image { BundledImage.load("plinth") }

    @MainActor public static func stage(_ stage: Stage) -> Image { BundledImage.load("stage-\(stage.rawValue)") }

    @MainActor public static func goal(_ goal: Goal) -> Image {
        let name = switch goal {
        case .stronger: "strong"
        case .habits: "protein"
        case .energy: "energy"
        case .sleep: "sleep"
        case .carry: "carry"
        case .family: "family"
        case .aches: "aches"
        case .independent: "independent"
        case .restart: "restart"
        case .comfortable: "comfortable"
        }
        return BundledImage.load("goal-\(name)")
    }

    /// A small paper vignette for a page: consent, birth, safety, body or training.
    @MainActor public static func badge(_ name: String) -> Image { BundledImage.load("scene-\(name)") }
}

/// Sign-in art from design/signin, light and dark: Bramble with an envelope,
/// Miso with her notebook, Otto with an hourglass.
public enum AuthArt {
    public enum Scene: String, Sendable { case inbox, returning, expired }

    /// The torn-paper hills with the eight coaches on their path, cut out of the design's picture. The sky is drawn
    /// in code (AuthSky) so it can move. 780 x 691 px.
    @MainActor public static func hills(dark: Bool) -> Image {
        BundledImage.load("auth-hills" + (dark ? "-dark" : ""))
    }

    public static let hillsAspect: CGFloat = 691.0 / 780.0

    @MainActor public static func image(_ scene: Scene, dark: Bool) -> Image {
        BundledImage.load("auth-\(scene.rawValue)" + (dark ? "-dark" : ""), ext: "jpg")
    }
}

/// Google's four-colour "G", from the design. Used on the Google sign-in button as Google's brand rules ask.
public struct GoogleMark: View {
    public init() {}

    private static let box = CGSize(width: 48, height: 48)

    public var body: some View {
        ZStack {
            SVGShape("M43.6 20.5H42V20H24v8h11.3C33.7 32.7 29.2 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.8 1.2 7.9 3.1l5.7-5.7C34 6.1 29.3 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20 20-8.9 20-20c0-1.3-.1-2.6-.4-3.5z", viewBox: Self.box)
                .fill(Color(red: 1, green: 0.757, blue: 0.027))
            SVGShape("M6.3 14.7l6.6 4.8C14.7 15.1 19 12 24 12c3.1 0 5.8 1.2 7.9 3.1l5.7-5.7C34 6.1 29.3 4 24 4 16.3 4 9.7 8.3 6.3 14.7z", viewBox: Self.box)
                .fill(Color(red: 1, green: 0.239, blue: 0))
            SVGShape("M24 44c5.2 0 9.9-2 13.4-5.2l-6.2-5.2C29.2 35.1 26.7 36 24 36c-5.2 0-9.6-3.3-11.3-7.9l-6.5 5C9.5 39.6 16.2 44 24 44z", viewBox: Self.box)
                .fill(Color(red: 0.298, green: 0.686, blue: 0.314))
            SVGShape("M43.6 20.5H42V20H24v8h11.3c-.8 2.2-2.2 4.2-4.1 5.6l6.2 5.2C37 39.2 44 34 44 24c0-1.3-.1-2.6-.4-3.5z", viewBox: Self.box)
                .fill(Color(red: 0.098, green: 0.463, blue: 0.824))
        }
        .accessibilityHidden(true)
    }
}
