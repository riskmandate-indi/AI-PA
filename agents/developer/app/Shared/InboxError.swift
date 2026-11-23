import Foundation

/// Every way saving a shared image can fail.
/// Each case has a short, specific message. There is no generic error.
enum InboxError: Error, Equatable {
    case appGroupUnavailable
    case emptyData
    case tooLarge(bytes: Int, limit: Int)
    case notAnImage
    case writeFailed(reason: String)

    /// Short text shown to the user.
    var userMessage: String {
        switch self {
        case .appGroupUnavailable:
            return "AIPA's shared storage is not set up. Open the AIPA app once, then try again."
        case .emptyData:
            return "That image was empty. Nothing was saved."
        case .tooLarge(_, let limit):
            let megabytes = limit / (1024 * 1024)
            return "That image is larger than \(megabytes) MB. Nothing was saved."
        case .notAnImage:
            return "That item is not an image AIPA can read. Nothing was saved."
        case .writeFailed:
            return "The phone could not store the image. Check free space, then try again."
        }
    }
}
