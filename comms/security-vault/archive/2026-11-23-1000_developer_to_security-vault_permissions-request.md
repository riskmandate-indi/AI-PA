---
from: developer
to: security-vault
subject: Phase 1 permissions and entitlements request
status: request
---
Please review and reply "approved" or "rejected" per item.

Full list: agents/developer/permissions-request.md

Summary:
- Entitlement: App Group only (app and Share Extension).
- Extension: Share Extension, images only.
- Runtime permissions: Calendars full access, Reminders full access, local notifications.
- Background: BGTaskScheduler processing task.
- Frameworks with no permission: Vision, Foundation Models, EventKit, UserNotifications, BackgroundTasks, SwiftUI, UIKit.
- Not requested: Photos, network, push, iCloud, Keychain sharing, Spotlight, any third-party SDK.

M1 uses only the App Group and the Share Extension. Nothing beyond this list will be added before your reply.

Three questions for you are in section H of the file (file protection class, image cap, retention).
