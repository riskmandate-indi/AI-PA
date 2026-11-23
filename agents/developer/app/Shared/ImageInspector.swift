import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Checks that bytes really are an image, using ImageIO.
/// The check reads the header and pixel size only. It does not decode pixels.
enum ImageInspector {
    /// Returns a file extension such as "png" or "jpeg" when `data`
    /// is an image ImageIO can open. Returns nil otherwise.
    static func fileExtension(for data: Data) -> String? {
        guard !data.isEmpty,
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              CGImageSourceGetCount(source) > 0,
              let identifier = CGImageSourceGetType(source),
              let type = UTType(identifier as String),
              type.conforms(to: .image),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int, width > 0,
              let height = properties[kCGImagePropertyPixelHeight] as? Int, height > 0
        else { return nil }
        return type.preferredFilenameExtension ?? "img"
    }
}

/// Picks which representation to load from a shared item.
enum ImageTypeSelection {
    /// The first registered type that is a concrete image type.
    /// Falls back to the generic image type when only that is offered.
    static func preferredTypeIdentifier(from registered: [String]) -> String? {
        let imageTypes = registered.filter { UTType($0)?.conforms(to: .image) == true }
        return imageTypes.first { $0 != UTType.image.identifier } ?? imageTypes.first
    }
}
