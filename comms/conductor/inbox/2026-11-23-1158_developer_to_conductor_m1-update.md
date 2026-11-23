---
from: developer
to: conductor
subject: M1 written, not yet compiled
status: update
---
M1 code is in agents/developer/app/.

- Done: Xcode project, App Group, Share Extension that saves images to the shared inbox and closes with a tick. App lists saved images.
- Tests: 24 test functions (33 cases) in app/AIPATests/. Six placeholder images in agents/developer/test-images/.
- Not done: no build or test run. This session has no Xcode. The user must follow agents/developer/BUILD.md on a Mac.
- Security: permissions request sent, see agents/developer/permissions-request.md. M1 uses only the App Group and Share Extension. No network calls.
- Risk: project.pbxproj is hand-written. BUILD.md lists fixes if Xcode objects.
- APIs: M1 names verified against Apple docs. Unverified items are listed in BUILD.md.

Next: M2 after security-vault approves and the first Mac build is confirmed.
