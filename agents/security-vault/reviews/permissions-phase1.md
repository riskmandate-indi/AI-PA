# Security gate decision: Phase 1 permissions and entitlements

- Reviewer: security-vault agent
- Date: 2026-11-23
- Request: [agents/developer/permissions-request.md](../../developer/permissions-request.md)
- Basis: [threat-model.md](../threat-model.md)
- Result: **approved**, all items, with the conditions below. Nothing rejected.

## Decisions per item

| Item | Decision | Conditions |
|---|---|---|
| A1 App Group | Approved | Only the app and its own Share Extension use the group. No other target joins without a new request. |
| B1 Share Extension, images only | Approved | Extension only copies the file and exits. No OCR, no model, no parsing in the extension. Limits in section "Answers" below. |
| C1 Calendars, full access | Approved | Ask at first use in M3, not at launch. The app edits or deletes only events it created itself, tracked by identifier. Any change to another event needs a user tap. Do not keep a copy of the whole calendar. Read the date range needed. |
| C2 Reminders, full access | Approved | Same rules as C1. Undo removes only reminders the app created. |
| C3 Local notifications | Approved | No remote push. No critical or time-sensitive entitlement. Sensitive types use hidden previews by default (threat T2). No tappable links (T11). Text comes from app templates (T25). |
| D1 Background processing task | Approved | One identifier only. The task does no network work. |
| E1 Vision | Approved | On-device requests only. |
| E2 Foundation Models | Approved | See "Model conditions" below. |
| E3, E4, E5 | Approved | Covered by C1 to C3 and D1. |
| E6 UI and system frameworks | Approved | OSLog: every dynamic value is private by default. F5 applies. |
| E7 Darwin notification | Approved | No payload, as stated. The app treats the ping as a hint and re-scans the folder. |
| F1, F3, F4, F5 | Approved | F4: update the manifest in the same commit as any required-reason API. |
| F2 file protection | Approved with a change | See answer 1. |
| G "not requested" list | Noted | This list is now binding. Each item needs a new request before use. |

## Model conditions (E2)

1. The session that reads untrusted text has no tools.
2. Output is a typed struct with a fixed schema. Swift code validates it.
3. Text from an image is data, never an instruction. See threat-model.md section 6.3.
4. Automatic actions: create one event, create one reminder, save one note. Nothing else.
5. At M2, confirm in writing that no Foundation Models call can leave the device (threat-model U1).
6. Keep a folder of synthetic injection test images. Run them at M2 and M3.

## Answers to section H

1. File protection class.
   - `Inbox/` in the shared container: `completeUntilFirstUserAuthentication` is accepted. Reason: share-and-forget needs background processing while locked. These files are short-lived.
   - Everything else is stricter:
     - Files written by background work (OCR text, derived records): `completeUnlessOpen`.
     - The main store and any retained images in the app's private container: `complete`.
   - Developer to confirm on a real device that background writes work with these classes. Report any exception by file.
2. Image cap.
   - 10 images per share is accepted.
   - Add: 20 MB per image. At most 50 files waiting in `Inbox/`. Over the limit, the extension says so plainly. No silent drop.
   - At most 3 automatic items created per image. More becomes one draft for review (T12).
3. Retention in the shared container.
   - Delete the `Inbox/` copy as soon as the image is processed.
   - If processing cannot run, move the image to the app's private container at the next app launch.
   - Nothing stays in the shared container longer than 7 days.
   - Retention inside the app is a user decision still open. Use 30 days until the conductor confirms.

## Not covered by this approval

- Email access. The concept doc lists "one email account" in Phase 1. That is a network call. It needs its own request with provider, protocol, scopes and hosts.
- Keychain use. Not requested. It will be needed with email tokens.
- PDF parsing. Not requested. Send a request before adding PDFKit input paths.
- Any Swift package, SDK, analytics or network call.

## Review at milestones

- M1: App Group scope, file protection, backup exclusion, extension does copy only.
- M2: model pipeline conditions, logs, injection tests.
- M3: EventKit write rules, notification content, Undo scope.
