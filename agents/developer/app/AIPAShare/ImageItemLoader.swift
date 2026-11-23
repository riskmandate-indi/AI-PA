import Foundation
import UniformTypeIdentifiers

/// Pulls image bytes out of the items handed over by the share sheet.
enum ImageItemLoader {
    /// All attachments in the share request that offer an image.
    static func imageProviders(in context: NSExtensionContext?) -> [NSItemProvider] {
        let items = (context?.inputItems ?? []).compactMap { $0 as? NSExtensionItem }
        return items
            .flatMap { $0.attachments ?? [] }
            .filter { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }
    }

    /// Returns the raw bytes and the type the share sheet declared for them.
    /// The bytes are not inspected here.
    static func loadImageData(from provider: NSItemProvider) async throws -> (data: Data, declaredType: String) {
        let typeIdentifier = ImageTypeSelection.preferredTypeIdentifier(from: provider.registeredTypeIdentifiers)
            ?? UTType.image.identifier
        return try await withCheckedThrowingContinuation { continuation in
            _ = provider.loadDataRepresentation(forTypeIdentifier: typeIdentifier) { data, _ in
                if let data {
                    continuation.resume(returning: (data, typeIdentifier))
                } else {
                    continuation.resume(throwing: InboxError.notAnImage)
                }
            }
        }
    }
}
