import SwiftUI
import SSCore
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/// Almond Warm palette. Source of truth: assets/README.md.
public enum Palette {
    // Light "Sketchbook" tokens and their dark twins from design/signin (ground #211B17, ink #F1E9DF).
    public static let ink = dynamic("#3B322C", "#F1E9DF")
    public static let ivory = dynamic("#FBF8F4", "#211B17")
    public static let almond = dynamic("#EDE3D6", "#3A322B")
    public static let taupe = color("#A8968A")
    public static let roseClay = color("#C08E82")
    public static let terracotta = color("#C2714F")
    public static let apricot = color("#F0C9A8")
    public static let honey = color("#E8C05F")
    public static let plumRose = color("#A9647A")
    public static let olive = color("#9AA88F")

    // Onboarding "Sketchbook" tokens from design/onboarding/line.src.html.
    public static let card = dynamic("#F6F0E8", "#2A231F")
    public static let ink2 = dynamic("#5D534B", "#B8AA9D")
    public static let pen = dynamic("#A85A3C", "#E09A78")
    public static let edge = ink.opacity(0.10)

    /// A colour that follows the phone's light or dark setting.
    private static func dynamic(_ light: String, _ dark: String) -> Color {
        guard let l = RGB(hex: light), let d = RGB(hex: dark) else { preconditionFailure("Invalid palette hex: \(light) \(dark)") }
        #if canImport(UIKit)
        return Color(UIColor { traits in
            let c = traits.userInterfaceStyle == .dark ? d : l
            return UIColor(red: c.red, green: c.green, blue: c.blue, alpha: 1)
        })
        #else
        return Color(NSColor(name: nil) { appearance in
            let c = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? d : l
            return NSColor(srgbRed: c.red, green: c.green, blue: c.blue, alpha: 1)
        })
        #endif
    }

    private static func color(_ hex: String) -> Color {
        guard let rgb = RGB(hex: hex) else { preconditionFailure("Invalid palette hex: \(hex)") }
        return Color(.sRGB, red: rgb.red, green: rgb.green, blue: rgb.blue)
    }
}
