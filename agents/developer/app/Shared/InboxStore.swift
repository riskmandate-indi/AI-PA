import Foundation

/// Saves shared images into a folder and lists them for processing.
///
/// Used by the Share Extension (save) and the app (list, remove).
/// Everything stays on the device. This type makes no network calls.
struct InboxStore {
    // Limits and retention set by security-vault,
    // agents/security-vault/reviews/permissions-phase1.md.
    /// 20 MB per image.
    static let defaultMaxBytes = 20 * 1024 * 1024
    /// At most 50 images may wait in the inbox.
    static let defaultMaxPending = 50
    /// Nothing stays in the shared container longer than 7 days.
    static let maxAge: TimeInterval = 7 * 24 * 60 * 60
    static let folderName = "Inbox"

    let directory: URL
    let maxBytes: Int
    let maxPending: Int
    private let fileManager: FileManager

    init(
        directory: URL,
        maxBytes: Int = InboxStore.defaultMaxBytes,
        maxPending: Int = InboxStore.defaultMaxPending,
        fileManager: FileManager = .default
    ) {
        self.directory = directory
        self.maxBytes = maxBytes
        self.maxPending = maxPending
        self.fileManager = fileManager
    }

    /// The inbox inside the App Group container.
    static func shared(fileManager: FileManager = .default) throws -> InboxStore {
        guard let container = AppGroup.containerURL(fileManager: fileManager) else {
            throw InboxError.appGroupUnavailable
        }
        return InboxStore(
            directory: container.appendingPathComponent(folderName, isDirectory: true),
            fileManager: fileManager
        )
    }

    /// Copies one shared image into the inbox. Returns the stored item.
    ///
    /// This is a copy only. The bytes are not opened, decoded or parsed
    /// here, because this runs inside the Share Extension. The app checks
    /// the bytes with `ImageInspector` before it reads an image.
    ///
    /// - Parameter declaredType: the type identifier the share sheet gave
    ///   for this item, for example "public.png".
    /// Nothing is written when a limit is exceeded.
    @discardableResult
    func save(imageData: Data, declaredType: String, now: Date = Date(), uuid: UUID = UUID()) throws -> InboxItem {
        guard !imageData.isEmpty else { throw InboxError.emptyData }
        guard imageData.count <= maxBytes else {
            throw InboxError.tooLarge(bytes: imageData.count, limit: maxBytes)
        }
        guard let fileExtension = ImageTypeSelection.fileExtension(forDeclaredType: declaredType) else {
            throw InboxError.notAnImage
        }
        let waiting = (try? pendingItems().count) ?? 0
        guard waiting < maxPending else { throw InboxError.inboxFull(limit: maxPending) }

        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            var folder = directory
            var folderValues = URLResourceValues()
            folderValues.isExcludedFromBackup = true
            try folder.setResourceValues(folderValues)

            let name = InboxFileName.make(date: now, uuid: uuid, fileExtension: fileExtension)
            var fileURL = directory.appendingPathComponent(name, isDirectory: false)
            // Atomic: the app never sees a half-written file.
            // Protection: readable after first unlock, so background
            // processing can run. Pending security-vault confirmation.
            try imageData.write(to: fileURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
            var fileValues = URLResourceValues()
            fileValues.isExcludedFromBackup = true
            try fileURL.setResourceValues(fileValues)

            guard let item = InboxFileName.parse(fileURL) else {
                throw InboxError.writeFailed(reason: "unexpected file name")
            }
            return item
        } catch let error as InboxError {
            throw error
        } catch {
            throw InboxError.writeFailed(reason: (error as NSError).domain + " \((error as NSError).code)")
        }
    }

    /// Images waiting to be processed, oldest first.
    /// Files the inbox did not create are ignored.
    func pendingItems() throws -> [InboxItem] {
        guard fileManager.fileExists(atPath: directory.path) else { return [] }
        let urls = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        return urls
            .compactMap(InboxFileName.parse)
            .sorted { $0.id < $1.id }
    }

    /// Deletes images that have waited longer than `maxAge`.
    /// Returns how many were deleted.
    @discardableResult
    func purgeExpired(now: Date = Date()) throws -> Int {
        let expired = try pendingItems().filter { now.timeIntervalSince($0.receivedAt) > InboxStore.maxAge }
        try expired.forEach(remove)
        return expired.count
    }

    /// Deletes one image from the inbox. Safe to call twice.
    func remove(_ item: InboxItem) throws {
        guard fileManager.fileExists(atPath: item.url.path) else { return }
        try fileManager.removeItem(at: item.url)
    }
}
