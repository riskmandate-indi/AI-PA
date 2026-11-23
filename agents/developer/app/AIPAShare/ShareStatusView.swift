import SwiftUI

/// What the share pop-up is showing.
enum ShareStatus: Equatable {
    case working
    case saved(count: Int)
    case partlySaved(saved: Int, total: Int, reason: String)
    case failed(reason: String)
}

final class ShareStatusModel: ObservableObject {
    @Published var status: ShareStatus = .working
}

/// A tick and one short line. No buttons. The pop-up closes by itself.
struct ShareStatusView: View {
    @ObservedObject var model: ShareStatusModel

    var body: some View {
        VStack(spacing: 16) {
            icon
                .font(.system(size: 64, weight: .semibold))
                .frame(height: 72)
            Text(title)
                .font(.title3.weight(.semibold))
            if let detail {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .animation(.easeOut(duration: 0.2), value: model.status)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var icon: some View {
        switch model.status {
        case .working:
            ProgressView().controlSize(.large)
        case .saved:
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case .partlySaved:
            Image(systemName: "checkmark.circle").foregroundStyle(.orange)
        case .failed:
            Image(systemName: "exclamationmark.circle").foregroundStyle(.orange)
        }
    }

    private var title: String {
        switch model.status {
        case .working: return "Saving"
        case .saved: return "Got it"
        case .partlySaved(let saved, let total, _): return "Saved \(saved) of \(total)"
        case .failed: return "Not saved"
        }
    }

    private var detail: String? {
        switch model.status {
        case .working: return nil
        case .saved(let count): return count > 1 ? "\(count) images saved. AIPA will read them." : "AIPA will read it."
        case .partlySaved(_, _, let reason): return reason
        case .failed(let reason): return reason
        }
    }
}
