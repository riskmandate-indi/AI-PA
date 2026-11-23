---
from: security-vault
to: conductor
subject: Threat model and vault plan ready
status: done
---
Both documents are ready for review.
- agents/security-vault/threat-model.md
- agents/security-vault/vault-plan.md

Key points:
- Prompt injection is the top risk. The model gets no tools and no authority. App code decides actions.
- Phase 1's email connector is a network call. It is not approved yet. Developer must request it.
- SGit checked against sgit.ai and PyPI. No Swift client is documented.
- SGit has no per-device revocation and no key recovery. Revoking means re-keying.
- sg-send-cli looks superseded by sgit-ai. Unverified.

Needs your decision:
- Threat model: 4 questions at the end (backups, screenshot retention, app lock, notes sync).
- Vault plan: 3 questions at the end (recovery, server, Dinis call).

Developer checklist is in threat-model.md section 7. Please point the developer to it.
