import Foundation

/// One image waiting in the shared inbox.
struct InboxItem: Identifiable, Equatable, Hashable {
    /// File name without extension. Unique per saved image.
    let id: String
    let url: URL
    /// When the Share Extension saved the image. Read from the file name,
    /// so no file timestamp API is needed.
    let receivedAt: Date
}

/// File names look like `20261123T115100123Z_<UUID>.png`.
/// The timestamp prefix keeps files sortable by name.
enum InboxFileName {
    private static let separator: Character = "_"

    private static func makeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyyMMdd'T'HHmmssSSS'Z'"
        return formatter
    }

    static func make(date: Date, uuid: UUID, fileExtension: String) -> String {
        "\(makeFormatter().string(from: date))\(separator)\(uuid.uuidString).\(fileExtension)"
    }

    /// Returns nil for any file that the inbox did not create.
    static func parse(_ url: URL) -> InboxItem? {
        let name = url.lastPathComponent
        guard !name.hasPrefix("."), !url.pathExtension.isEmpty else { return nil }
        let stem = url.deletingPathExtension().lastPathComponent
        let parts = stem.split(separator: separator, maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2,
              let date = makeFormatter().date(from: String(parts[0])),
              UUID(uuidString: String(parts[1])) != nil
        else { return nil }
        return InboxItem(id: stem, url: url, receivedAt: date)
    }
}
