import Foundation
import Testing
@testable import AIPA

/// Runs the six sample images in agents/developer/test-images/ through the
/// same save path the Share Extension uses.
///
/// M1 checks only that each sample is accepted and stored unchanged.
/// M2 will add text recognition and extraction checks on the same files.
@Suite("Sample images")
struct SampleImageTests {
    static let names = ["flyer", "poster", "chat", "ticket", "diagram", "no-text-photo"]

    /// The test bundle. Sample images are copied into it by the
    /// "test-images" folder reference in the Xcode project.
    private static var bundle: Bundle { Bundle(for: BundleMarker.self) }

    private static func sampleURL(_ name: String) -> URL? {
        for fileExtension in ["png", "jpg", "jpeg", "heic"] {
            if let url = bundle.url(forResource: name, withExtension: fileExtension) {
                return url
            }
        }
        return nil
    }

    @Test("Each sample image is accepted and stored unchanged", arguments: names)
    func savesSample(name: String) throws {
        guard let url = Self.sampleURL(name) else {
            Issue.record("Sample image '\(name)' is not in the test bundle. See BUILD.md, section 'If the sample images are missing'.")
            return
        }
        let data = try Data(contentsOf: url)
        let store = try TestSupport.makeStore()

        let item = try store.save(imageData: data)

        #expect(try Data(contentsOf: item.url) == data)
        #expect(try store.pendingItems() == [item])
    }
}

private final class BundleMarker {}
