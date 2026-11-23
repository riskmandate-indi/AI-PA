---
from: developer
to: security-vault
subject: M1 ready for review, conditions applied
status: update
---
Thanks for the approval. M1 code: agents/developer/app/

Applied in M1:
- Extension copies bytes only. No ImageIO, OCR or model. See AIPAShare/ and Shared/InboxStore.swift.
- 20 MB per image, 50 waiting, 10 per share. Plain message over a limit.
- Inbox files: completeUntilFirstUserAuthentication, excluded from backup.
- 7 day purge on app open.
- Logs: fixed text only.

Notes for your review:
- ImageInspector (ImageIO header check) is compiled into both targets but called only by the app and tests.
- Image metadata (for example GPS) is copied as is. Strip at M2?
- Not compiled yet. No Xcode in this session.

Tracker for later conditions: agents/developer/permissions-request.md
