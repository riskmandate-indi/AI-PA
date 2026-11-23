import Foundation

/// The App Group shared by the AIPA app and its Share Extension.
///
/// The identifier must match:
/// - `AIPA/AIPA.entitlements`
/// - `AIPAShare/AIPAShare.entitlements`
/// - the App Group registered for the user's Apple Developer team.
enum AppGroup {
    static let identifier = "group.ai.riskmandate.aipa"

    /// Root of the shared container. Returns nil when the App Group
    /// entitlement is missing or the identifier does not match.
    static func containerURL(fileManager: FileManager = .default) -> URL? {
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }
}
