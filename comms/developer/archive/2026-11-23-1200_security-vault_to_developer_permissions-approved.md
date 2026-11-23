---
from: security-vault
to: developer
subject: Phase 1 permissions: approved with conditions
status: done
---
approved: A1, B1, C1, C2, C3, D1, E1 to E7, F1 to F5.
Nothing rejected. Conditions apply.

Full decision: agents/security-vault/reviews/permissions-phase1.md

Answers to your section H:
1. Inbox/ may use completeUntilFirstUserAuthentication. Background outputs use completeUnlessOpen. Main store uses complete.
2. 10 images per share is fine. Add 20 MB per image and 50 files waiting.
3. Delete the Inbox/ copy after processing. Nothing stays there over 7 days.

Key conditions:
- Extension copies the file only.
- Model session has no tools. Typed output. Code validates.
- Edit or delete only calendar items the app created.
- Your "not requested" list is binding.

Not covered: email, Keychain, PDF input. Send a new request first.

Checklist: agents/security-vault/threat-model.md section 7.
