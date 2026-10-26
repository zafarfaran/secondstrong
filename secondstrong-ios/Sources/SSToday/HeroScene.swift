import SwiftUI
import SSCore
import SSDesign

/// The paper scene with the coach standing on its hill. The scene is placed so the hill sits at a fixed spot, whatever the
/// phone's width, and the coach's feet land on it.
struct HeroScene: View {
    let part: DayPart
    let coach: Coach
    let mood: CoachMood
    let width: CGFloat
    let height: CGFloat
    /// Where the hill should sit, as fractions of the hero.
    var anchor = CGPoint(x: 0.65, y: 0.80)
    var coachSize: CGFloat = 200
    var animated = true
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let scene = PaperArt.todayScene(part, dark: scheme == .dark)
        let imageWidth = width * 1.97, imageHeight = imageWidth / 1.5
        let target = CGPoint(x: width * anchor.x, y: height * anchor.y)
        let top = min(0, target.y - scene.plateau.y * imageHeight)
        let hill = CGPoint(x: target.x, y: top + scene.plateau.y * imageHeight)
        ZStack(alignment: .topLeading) {
            scene.image.resizable()
                .frame(width: imageWidth, height: imageHeight)
                .offset(x: target.x - scene.plateau.x * imageWidth, y: top)
            CoachView(coach, mood: mood, animated: animated)
                .frame(width: coachSize, height: coachSize)
                .offset(x: hill.x - coachSize / 2, y: hill.y - coachSize * 0.905)
                .allowsHitTesting(false)
        }
        .frame(width: width, height: height, alignment: .topLeading)
        .clipped()
        .accessibilityHidden(true)
    }
}
