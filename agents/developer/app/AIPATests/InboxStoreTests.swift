import Foundation
import Testing
@testable import AIPA

@Suite("InboxStore")
struct InboxStoreTests {

    @Test("Saving a PNG writes an identical file into the inbox")
    func savesPNG() throws {
        let store = try TestSupport.makeStore()
        let data = TestSupport.pngData()

        let item = try store.save(imageData: data, declaredType: "public.png")

        #expect(item.url.pathExtension == "png")
        #expect(item.url.deletingLastPathComponent().standardizedFileURL == store.directory.standardizedFileURL)
        #expect(try Data(contentsOf: item.url) == data)
    }

    @Test("Saving a JPEG keeps a JPEG extension")
    func savesJPEG() throws {
        let store = try TestSupport.makeStore()
        let item = try store.save(imageData: TestSupport.jpegData(), declaredType: "public.jpeg")
        #expect(["jpeg", "jpg"].contains(item.url.pathExtension))
    }

    @Test("The inbox folder is created on first save")
    func createsFolder() throws {
        let store = try TestSupport.makeStore()
        #expect(!FileManager.default.fileExists(atPath: store.directory.path))
        try store.save(imageData: TestSupport.pngData(), declaredType: "public.png")
        #expect(FileManager.default.fileExists(atPath: store.directory.path))
    }

    @Test("Empty data is rejected")
    func rejectsEmpty() throws {
        let store = try TestSupport.makeStore()
        #expect(throws: InboxError.emptyData) {
            try store.save(imageData: Data(), declaredType: "public.png")
        }
        #expect(try store.pendingItems().isEmpty)
    }

    @Test("An item declared as text or PDF is rejected and nothing is written", arguments: [
        "public.plain-text", "com.adobe.pdf", "public.url", "not a type",
    ])
    func rejectsNonImageType(declaredType: String) throws {
        let store = try TestSupport.makeStore()
        #expect(throws: InboxError.notAnImage) {
            try store.save(imageData: TestSupport.pngData(), declaredType: declaredType)
        }
        #expect(try store.pendingItems().isEmpty)
    }

    @Test("The extension copy does not alter or inspect the bytes")
    func copiesBytesUnchanged() throws {
        let store = try TestSupport.makeStore()
        let bytes = Data("not really a png".utf8)
        let item = try store.save(imageData: bytes, declaredType: "public.png")
        #expect(try Data(contentsOf: item.url) == bytes)
        // The app-side check then refuses to treat it as an image.
        #expect(ImageInspector.fileExtension(for: try Data(contentsOf: item.url)) == nil)
    }

    @Test("A generic image type gets a neutral extension")
    func genericImageType() throws {
        let store = try TestSupport.makeStore()
        let item = try store.save(imageData: TestSupport.pngData(), declaredType: "public.image")
        #expect(!item.url.pathExtension.isEmpty)
        #expect(try store.pendingItems() == [item])
    }

    @Test("The inbox refuses new images once the waiting limit is reached")
    func rejectsWhenFull() throws {
        let root = try TestSupport.makeTempDirectory()
        let store = InboxStore(directory: root.appendingPathComponent("Inbox"), maxPending: 2)
        try store.save(imageData: TestSupport.pngData(), declaredType: "public.png")
        try store.save(imageData: TestSupport.pngData(), declaredType: "public.png")
        #expect(throws: InboxError.inboxFull(limit: 2)) {
            try store.save(imageData: TestSupport.pngData(), declaredType: "public.png")
        }
        #expect(try store.pendingItems().count == 2)
    }

    @Test("The security limits are 20 MB per image, 50 waiting, 7 days")
    func securityLimits() {
        #expect(InboxStore.defaultMaxBytes == 20 * 1024 * 1024)
        #expect(InboxStore.defaultMaxPending == 50)
        #expect(InboxStore.maxAge == 7 * 24 * 60 * 60)
    }

    @Test("Images older than 7 days are purged. Newer ones stay")
    func purgesExpired() throws {
        let store = try TestSupport.makeStore()
        let now = TestSupport.date("2026-08-20T12:00:00Z")
        let old = try store.save(imageData: TestSupport.pngData(), declaredType: "public.png", now: TestSupport.date("2026-08-13T11:59:00Z"))
        let fresh = try store.save(imageData: TestSupport.pngData(), declaredType: "public.png", now: TestSupport.date("2026-08-13T12:01:00Z"))

        let removed = try store.purgeExpired(now: now)

        #expect(removed == 1)
        #expect(!FileManager.default.fileExists(atPath: old.url.path))
        #expect(try store.pendingItems() == [fresh])
    }

    @Test("Images over the size limit are rejected")
    func rejectsTooLarge() throws {
        let data = TestSupport.pngData()
        let store = try TestSupport.makeStore(maxBytes: data.count - 1)
        #expect(throws: InboxError.tooLarge(bytes: data.count, limit: data.count - 1)) {
            try store.save(imageData: data, declaredType: "public.png")
        }
        #expect(try store.pendingItems().isEmpty)
    }

    @Test("An image exactly at the size limit is accepted")
    func acceptsAtLimit() throws {
        let data = TestSupport.pngData()
        let store = try TestSupport.makeStore(maxBytes: data.count)
        try store.save(imageData: data, declaredType: "public.png")
        #expect(try store.pendingItems().count == 1)
    }

    @Test("Pending items are listed oldest first")
    func listsOldestFirst() throws {
        let store = try TestSupport.makeStore()
        let data = TestSupport.pngData()
        let late = try store.save(imageData: data, declaredType: "public.png", now: TestSupport.date("2026-08-15T21:00:00Z"))
        let early = try store.save(imageData: data, declaredType: "public.png", now: TestSupport.date("2026-08-14T08:30:00Z"))
        let middle = try store.save(imageData: data, declaredType: "public.png", now: TestSupport.date("2026-08-15T09:00:00Z"))

        #expect(try store.pendingItems().map(\.id) == [early.id, middle.id, late.id])
    }

    @Test("Two saves in the same instant get different files")
    func uniqueNames() throws {
        let store = try TestSupport.makeStore()
        let now = TestSupport.date("2026-08-15T21:00:00Z")
        let first = try store.save(imageData: TestSupport.pngData(), declaredType: "public.png", now: now)
        let second = try store.save(imageData: TestSupport.pngData(), declaredType: "public.png", now: now)
        #expect(first.id != second.id)
        #expect(try store.pendingItems().count == 2)
    }

    @Test("An empty or missing inbox lists nothing")
    func emptyInbox() throws {
        let store = try TestSupport.makeStore()
        #expect(try store.pendingItems().isEmpty)
    }

    @Test("Files the inbox did not create are ignored")
    func ignoresStrayFiles() throws {
        let store = try TestSupport.makeStore()
        let item = try store.save(imageData: TestSupport.pngData(), declaredType: "public.png")
        try Data("x".utf8).write(to: store.directory.appendingPathComponent("notes.txt"))
        try Data("x".utf8).write(to: store.directory.appendingPathComponent(".hidden.png"))
        try Data("x".utf8).write(to: store.directory.appendingPathComponent("not-a-date_\(UUID().uuidString).png"))

        #expect(try store.pendingItems() == [item])
    }

    @Test("Removing an item deletes its file and is safe to repeat")
    func removes() throws {
        let store = try TestSupport.makeStore()
        let item = try store.save(imageData: TestSupport.pngData(), declaredType: "public.png")

        try store.remove(item)
        try store.remove(item)

        #expect(!FileManager.default.fileExists(atPath: item.url.path))
        #expect(try store.pendingItems().isEmpty)
    }

    @Test("Saved images are excluded from backup")
    func excludedFromBackup() throws {
        let store = try TestSupport.makeStore()
        let item = try store.save(imageData: TestSupport.pngData(), declaredType: "public.png")
        let values = try item.url.resourceValues(forKeys: [.isExcludedFromBackupKey])
        #expect(values.isExcludedFromBackup == true)
    }

    @Test("The received time survives the round trip through the file name")
    func receivedAtRoundTrip() throws {
        let store = try TestSupport.makeStore()
        let now = TestSupport.date("2026-08-15T21:00:00Z")
        let item = try store.save(imageData: TestSupport.pngData(), declaredType: "public.png", now: now)
        #expect(item.receivedAt == now)
        #expect(try store.pendingItems().first?.receivedAt == now)
    }
}

@Suite("InboxFileName")
struct InboxFileNameTests {
    @Test("Names are built as timestamp, underscore, UUID, extension")
    func makesName() {
        let uuid = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
        let name = InboxFileName.make(date: TestSupport.date("2026-11-23T11:51:00Z"), uuid: uuid, fileExtension: "png")
        #expect(name == "20261123T115100000Z_11111111-2222-3333-4444-555555555555.png")
    }

    @Test("Names that do not match the pattern are not parsed", arguments: [
        "photo.png",
        "20261123T115100000Z.png",
        "20261123T115100000Z_not-a-uuid.png",
        "20261123T115100000Z_11111111-2222-3333-4444-555555555555",
        ".20261123T115100000Z_11111111-2222-3333-4444-555555555555.png",
    ])
    func rejectsOtherNames(name: String) {
        let url = URL(fileURLWithPath: "/tmp").appendingPathComponent(name)
        #expect(InboxFileName.parse(url) == nil)
    }
}

@Suite("Image checks")
struct ImageChecksTests {
    @Test("PNG and JPEG bytes are recognised")
    func recognisesImages() {
        #expect(ImageInspector.fileExtension(for: TestSupport.pngData()) == "png")
        #expect(["jpeg", "jpg"].contains(ImageInspector.fileExtension(for: TestSupport.jpegData()) ?? ""))
    }

    @Test("A truncated PNG header is not an image")
    func rejectsTruncatedHeader() {
        let fake = Data([0x89, 0x50, 0x4E, 0x47]) + Data(repeating: 0, count: 8)
        #expect(ImageInspector.fileExtension(for: fake) == nil)
    }

    @Test("Declared image types map to a file extension. Others do not")
    func declaredTypeExtension() {
        #expect(ImageTypeSelection.fileExtension(forDeclaredType: "public.png") == "png")
        #expect(ImageTypeSelection.fileExtension(forDeclaredType: "public.image") != nil)
        #expect(ImageTypeSelection.fileExtension(forDeclaredType: "public.plain-text") == nil)
        #expect(ImageTypeSelection.fileExtension(forDeclaredType: "") == nil)
    }

    @Test("Text, PDF headers and empty data are not images")
    func rejectsOthers() {
        #expect(ImageInspector.fileExtension(for: Data()) == nil)
        #expect(ImageInspector.fileExtension(for: Data("hello".utf8)) == nil)
        #expect(ImageInspector.fileExtension(for: Data("%PDF-1.7\n".utf8)) == nil)
    }

    @Test("A concrete image type is preferred over the generic one")
    func prefersConcreteType() {
        #expect(ImageTypeSelection.preferredTypeIdentifier(from: ["public.image", "public.png"]) == "public.png")
        #expect(ImageTypeSelection.preferredTypeIdentifier(from: ["public.jpeg", "public.png"]) == "public.jpeg")
        #expect(ImageTypeSelection.preferredTypeIdentifier(from: ["public.heic"]) == "public.heic")
    }

    @Test("The generic image type is used when it is the only one")
    func fallsBackToGeneric() {
        #expect(ImageTypeSelection.preferredTypeIdentifier(from: ["public.image"]) == "public.image")
    }

    @Test("Non-image types are never chosen")
    func ignoresNonImages() {
        #expect(ImageTypeSelection.preferredTypeIdentifier(from: ["public.plain-text", "public.url", "com.adobe.pdf"]) == nil)
        #expect(ImageTypeSelection.preferredTypeIdentifier(from: []) == nil)
    }

    @Test("Every failure has its own short message")
    func errorMessages() {
        let errors: [InboxError] = [
            .appGroupUnavailable, .emptyData, .tooLarge(bytes: 2, limit: 1), .notAnImage, .inboxFull(limit: 50),
            .writeFailed(reason: "x"),
        ]
        let messages = errors.map(\.userMessage)
        #expect(Set(messages).count == errors.count)
        #expect(messages.allSatisfy { !$0.isEmpty && $0.count < 120 })
    }
}
