import OSLog
import SwiftUI
import UIKit

/// Entry point of the Share Extension.
///
/// It does one job: copy the shared images into the App Group inbox,
/// show a tick and close. It never opens, decodes or reads the images. All reading and reasoning happens later in
/// the main app, because extensions have tight memory and time limits.
final class ShareViewController: UIViewController {
    private let model = ShareStatusModel()
    private let log = Logger(subsystem: "ai.riskmandate.aipa.share", category: "share")
    private var hasStarted = false

    /// How long the tick stays on screen before the pop-up closes.
    private static let successDelay: Duration = .milliseconds(900)
    /// Problems stay a little longer so the message can be read.
    private static let problemDelay: Duration = .milliseconds(2800)

    override func viewDidLoad() {
        super.viewDidLoad()
        let host = UIHostingController(rootView: ShareStatusView(model: model))
        addChild(host)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(host.view)
        host.didMove(toParent: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasStarted else { return }
        hasStarted = true
        Task { @MainActor in
            let status = await saveSharedImages()
            await finish(with: status)
        }
    }

    @MainActor
    private func saveSharedImages() async -> ShareStatus {
        let providers = ImageItemLoader.imageProviders(in: extensionContext)
        guard !providers.isEmpty else {
            return .failed(reason: "No image was found in what you shared.")
        }

        let store: InboxStore
        do {
            store = try InboxStore.shared()
        } catch {
            return .failed(reason: Self.message(for: error))
        }

        var savedCount = 0
        var lastProblem: String?
        for provider in providers {
            do {
                let loaded = try await ImageItemLoader.loadImageData(from: provider)
                try store.save(imageData: loaded.data, declaredType: loaded.declaredType)
                savedCount += 1
            } catch {
                lastProblem = Self.message(for: error)
            }
        }

        // Fixed text only. No image content, names or other dynamic values.
        if savedCount == providers.count {
            log.info("Share finished. All images saved.")
        } else {
            log.info("Share finished. Some images were not saved.")
        }

        if savedCount == providers.count {
            return .saved(count: savedCount)
        }
        let reason = lastProblem ?? InboxError.notAnImage.userMessage
        if savedCount > 0 {
            return .partlySaved(saved: savedCount, total: providers.count, reason: reason)
        }
        return .failed(reason: reason)
    }

    @MainActor
    private func finish(with status: ShareStatus) async {
        model.status = status
        let feedback = UINotificationFeedbackGenerator()
        switch status {
        case .saved:
            feedback.notificationOccurred(.success)
            try? await Task.sleep(for: Self.successDelay)
        case .partlySaved, .failed, .working:
            feedback.notificationOccurred(.warning)
            try? await Task.sleep(for: Self.problemDelay)
        }
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    private static func message(for error: Error) -> String {
        (error as? InboxError)?.userMessage ?? InboxError.writeFailed(reason: "").userMessage
    }
}
