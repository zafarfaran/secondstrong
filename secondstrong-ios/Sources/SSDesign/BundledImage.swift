import ImageIO
import SwiftUI

/// Loads PNGs from the module bundle. Plain files rather than an asset catalog,
/// so they load the same under `swift build`, `swift test` and Xcode.
enum BundledImage {
    @MainActor private static var cache: [String: Image] = [:]

    @MainActor static func load(_ name: String, in directory: String = "Images", ext: String = "png") -> Image {
        let key = directory + "/" + name
        if let hit = cache[key] { return hit }
        guard let url = Bundle.module.url(forResource: name, withExtension: ext, subdirectory: directory)
                ?? Bundle.module.url(forResource: name, withExtension: ext),
              let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let picture = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { return Image(systemName: "questionmark.square") }
        let image = Image(decorative: picture, scale: 1)
        cache[key] = image
        return image
    }
}
