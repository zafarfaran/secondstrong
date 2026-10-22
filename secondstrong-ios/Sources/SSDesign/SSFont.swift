import CoreText
import SwiftUI

/// The app's two typefaces, both SIL OFL (see Resources/Fonts): Gochi Hand for the emphasised word
/// in a heading and the coach's voice, Bricolage Grotesque for everything else. Weights and optical
/// sizes are set through variable-font axes, which SwiftUI's weight modifier does not reach.
public enum SSFont {
    private static let registered: Void = {
        for name in ["BricolageGrotesque", "GochiHand-Regular"] {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts")
                ?? Bundle.module.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }()

    private static let weightAxis: UInt32 = 0x7767_6874
    private static let opticalAxis: UInt32 = 0x6F70_737A

    /// Bricolage Grotesque: 800 for titles, 600 for buttons, 400 for body.
    public static func display(_ size: CGFloat, weight: Double = 800) -> Font {
        variable("BricolageGrotesque-96ptExtraBold", size, [weightAxis: weight, opticalAxis: min(96, max(12, size))])
    }

    /// Gochi Hand: a heading's emphasised word and the coach's handwriting.
    public static func hand(_ size: CGFloat) -> Font { fixed("GochiHand-Regular", size) }

    private static func fixed(_ name: String, _ size: CGFloat) -> Font {
        _ = registered
        return .custom(name, fixedSize: size)
    }

    private static func variable(_ name: String, _ size: CGFloat, _ axes: [UInt32: Double]) -> Font {
        _ = registered
        let variations = Dictionary(uniqueKeysWithValues: axes.map { (NSNumber(value: $0.key), NSNumber(value: $0.value)) })
        let descriptor = CTFontDescriptorCreateWithAttributes([
            kCTFontNameAttribute: name,
            kCTFontVariationAttribute: variations,
        ] as CFDictionary)
        return Font(CTFontCreateWithFontDescriptor(descriptor, size, nil))
    }
}
