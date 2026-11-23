import Foundation

/// Saves shared images into a folder and lists them for processing.
///
/// Used by the Share Extension (save) and the app (list, remove).
/// Everything stays on the device. This type makes no network calls.
struct InboxStore {
    /// 25 MB. Screenshots are far smaller. The cap protects the
    /// Share Extension, which has a tight memory limit.
    static let defaultMaxBytes = 25 * 1024 * 1024
    static let folderName = "Inbox"

    let directory: URL
    let maxBytes: Int
    private let fileManager: FileManager

    init(directory: URL, maxBytes: Int = InboxStore.defaultMaxBytes, fileManager: FileManager = .default) {
        self.directory = directory
        self.maxBytes = maxBytes
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

    /// Validates and stores one image. Returns the stored item.
    /// Nothing is written when validation fails.
    @discardableResult
    func save(imageData: Data, now: Date = Date(), uuid: UUID = UUID()) throws -> InboxItem {
        guard !imageData.isEmpty else { throw InboxError.emptyData }
        guard imageData.count <= maxBytes else {
            throw InboxError.tooLarge(bytes: imageData.count, limit: maxBytes)
        }
        guard let fileExtension = ImageInspector.fileExtension(for: imageData) else {
            throw InboxError.notAnImage
        }

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

    /// Deletes one image from the inbox. Safe to call twice.
    func remove(_ item: InboxItem) throws {
        guard fileManager.fileExists(atPath: item.url.path) else { return }
        try fileManager.removeItem(at: item.url)
    }
}
