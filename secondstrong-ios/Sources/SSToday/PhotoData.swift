import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

extension Image {
    /// A picture from the bytes of a chosen photo, or nil when they are not an image.
    init?(photoData: Data) {
        #if canImport(UIKit)
        guard let image = UIImage(data: photoData) else { return nil }
        self.init(uiImage: image)
        #else
        guard let image = NSImage(data: photoData) else { return nil }
        self.init(nsImage: image)
        #endif
    }
}
