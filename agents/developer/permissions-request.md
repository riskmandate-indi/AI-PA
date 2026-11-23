# Developer: permissions and entitlements request (Phase 1)

Sent to security-vault on 2026-11-23. Status: awaiting reply.
Scope: iOS app "AIPA" plus its Share Extension. No network. Apple frameworks only.

Placeholder identifiers (the user may change them, the shape stays the same):
- App bundle ID: `ai.riskmandate.aipa`
- Share Extension bundle ID: `ai.riskmandate.aipa.share`
- App Group: `group.ai.riskmandate.aipa`

## A. Entitlements (signed into the binary)

| # | Entitlement | Targets | Milestone | Why |
|---|---|---|---|---|
| A1 | App Groups: `com.apple.security.application-groups` = `group.ai.riskmandate.aipa` | App, Share Extension | M1 | Extension saves the shared image into a shared folder. App reads it. |

That is the only entitlement requested.

## B. Extension points

| # | Item | Milestone | Detail |
|---|---|---|---|
| B1 | Share Extension, `com.apple.share-services` | M1 | Activation rule: images only, `NSExtensionActivationSupportsImageWithMaxCount` = 10. No text, URLs, files or web pages. |

## C. User permissions (runtime prompts, Info.plist usage strings)

| # | Permission | Info.plist key | Milestone | Why |
|---|---|---|---|---|
| C1 | Calendars, full access | `NSCalendarsFullAccessUsageDescription` | M3 | Read events to cross-check dates. Create events. Full access is needed because write-only cannot read. |
| C2 | Reminders, full access | `NSRemindersFullAccessUsageDescription` | M3 | Create reminders and remove them on Undo. |
| C3 | Local notifications (alert, sound) | none, `UNUserNotificationCenter.requestAuthorization` | M3 | Confirm results with an Undo action. Local only. No remote push, no `aps-environment`. |

## D. Background execution

| # | Item | Info.plist key | Milestone | Why |
|---|---|---|---|---|
| D1 | Background processing task | `UIBackgroundModes` = `processing`, `BGTaskSchedulerPermittedIdentifiers` = `ai.riskmandate.aipa.process-inbox` | M2 | Process saved images when the app is not in front. |

## E. Apple frameworks that need no permission or entitlement

| # | Framework | Milestone | Use |
|---|---|---|---|
| E1 | Vision | M2 | On-device text recognition on the saved image. |
| E2 | Foundation Models | M2 | On-device extraction into a typed struct. Availability is checked first. Needs Apple Intelligence turned on by the user. |
| E3 | EventKit | M3 | Used under C1 and C2. |
| E4 | UserNotifications | M3 | Used under C3. |
| E5 | BackgroundTasks | M2 | Used under D1. |
| E6 | SwiftUI, UIKit, Foundation, UniformTypeIdentifiers, ImageIO, CoreGraphics, OSLog | M1 | UI, file handling, image type checks, local logging. |
| E7 | Darwin notification (CFNotificationCenter) | M2 | Extension pings the app that a new image exists. Carries no payload. |

## F. Storage and data protection

- F1. Shared container folder `Inbox/` holds the shared images. Written atomically.
- F2. File protection set per file to `completeUntilFirstUserAuthentication`. Reason: background processing must read files after first unlock. No data protection entitlement is needed for per-file attributes. If you prefer `complete`, say so and D1 will only run while unlocked.
- F3. Files are excluded from iCloud and iTunes backup (`isExcludedFromBackup`).
- F4. Privacy manifest `PrivacyInfo.xcprivacy` in both targets: no tracking, no collected data, no tracking domains. Required-reason APIs will be declared if and when used.
- F5. Logs never contain image content or recognised text. Only counts and file IDs.

## G. Explicitly NOT requested

- Photos library access. The share sheet hands over the image, so no `NSPhotoLibraryUsageDescription`.
- Camera, microphone, location, contacts, Siri, HealthKit.
- Network of any kind. No URLSession, no ATS exceptions, no push, no iCloud, no CloudKit.
- Keychain sharing, associated domains, Sign in with Apple.
- Analytics, crash reporters, third-party SDKs, Swift packages.
- Core Spotlight indexing. "Searchable note" will be in-app search only unless you approve Spotlight later.

## H. Questions for security-vault

1. F2: `completeUntilFirstUserAuthentication` or `complete` for inbox images?
2. B1: is a cap of 10 images per share acceptable?
3. Any rule on how long processed images may stay in the shared container?
