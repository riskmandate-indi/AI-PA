import Foundation

/// Loads the list of images waiting in the shared inbox.
final class InboxViewModel: ObservableObject {
    enum State: Equatable {
        case loaded([InboxItem])
        case problem(String)
    }

    @Published private(set) var state: State = .loaded([])

    private let makeStore: () throws -> InboxStore

    init(makeStore: @escaping () throws -> InboxStore = { try InboxStore.shared() }) {
        self.makeStore = makeStore
    }

    func refresh() {
        do {
            state = .loaded(try makeStore().pendingItems())
        } catch let error as InboxError {
            state = .problem(error.userMessage)
        } catch {
            state = .problem("The saved images could not be listed. Close and reopen AIPA.")
        }
    }

    func remove(_ item: InboxItem) {
        do {
            try makeStore().remove(item)
        } catch {
            state = .problem("That image could not be removed. Close and reopen AIPA.")
            return
        }
        refresh()
    }
}
