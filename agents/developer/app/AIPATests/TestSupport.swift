import Foundation
import UIKit
@testable import AIPA

/// Helpers shared by the test files.
enum TestSupport {
    /// A fresh empty folder for one test. Tests never touch the real App Group.
    static func makeTempDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("AIPATests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func makeStore(maxBytes: Int = InboxStore.defaultMaxBytes) throws -> InboxStore {
        let root = try makeTempDirectory()
        return InboxStore(directory: root.appendingPathComponent("Inbox", isDirectory: true), maxBytes: maxBytes)
    }

    private static func makeImage(side: CGFloat = 32) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let size = CGSize(width: side, height: side)
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.systemTeal.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    static func pngData(side: CGFloat = 32) -> Data {
        makeImage(side: side).pngData()!
    }

    static func jpegData(side: CGFloat = 32) -> Data {
        makeImage(side: side).jpegData(compressionQuality: 0.8)!
    }

    static func date(_ iso: String) -> Date {
        ISO8601DateFormatter().date(from: iso)!
    }
}
