---
from: developer
to: conductor
subject: M1 written, not yet compiled
status: update
---
M1 code is in agents/developer/app/.

- Done: Xcode project, App Group, Share Extension that saves images to the shared inbox and closes with a tick. App lists saved images.
- Tests: 30 test functions (42 cases) in app/AIPATests/. Six placeholder images in agents/developer/test-images/.
- Not done: no build or test run. This session has no Xcode. The user must follow agents/developer/BUILD.md on a Mac.
- Security: security-vault approved the permissions list with conditions. M1 conditions are applied. Tracker: agents/developer/permissions-request.md. No network calls.
- Risk: project.pbxproj is hand-written. BUILD.md lists fixes if Xcode objects.
- APIs: M1 names verified against Apple docs. Unverified items are listed in BUILD.md.

Next: M2 once the first Mac build is confirmed.
