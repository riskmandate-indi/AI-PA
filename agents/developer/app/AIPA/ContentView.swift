import SwiftUI
import UIKit

/// Milestone 1 screen: shows the images the Share Extension has saved.
/// Reading and acting on them arrives in Milestone 2 and later.
struct ContentView: View {
    @StateObject private var model = InboxViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("AIPA")
        }
        .onAppear { model.refresh() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { model.refresh() }
        }
    }

    @ViewBuilder private var content: some View {
        switch model.state {
        case .problem(let message):
            ContentUnavailableView("Something needs attention", systemImage: "exclamationmark.circle", description: Text(message))
        case .loaded(let items) where items.isEmpty:
            ContentUnavailableView(
                "Nothing waiting",
                systemImage: "tray",
                description: Text("Take a screenshot, tap Share, then tap AIPA.")
            )
        case .loaded(let items):
            List {
                Section("Waiting to be read (\(items.count))") {
                    ForEach(items) { item in
                        InboxRow(item: item)
                    }
                    .onDelete { offsets in
                        offsets.map { items[$0] }.forEach(model.remove)
                    }
                }
            }
        }
    }
}

private struct InboxRow: View {
    let item: InboxItem

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text("Shared image")
                Text(item.receivedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder private var thumbnail: some View {
        if let image = UIImage(contentsOfFile: item.url.path)?
            .preparingThumbnail(of: CGSize(width: 144, height: 144)) {
            Image(uiImage: image).resizable().scaledToFill()
        } else {
            Image(systemName: "photo").foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
