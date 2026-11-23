# Vault questions for Dinis Cruz

- Owner: security-vault agent
- Date: 2026-11-23
- Shareable copy (Claude Doc): https://claude.ai/artifact/X3EF9pBrF2FcCnoCEWpjsF
- Detail behind each question: [vault-plan.md](vault-plan.md) section 4
- Use: the 60 minute review call. Questions 1 to 4 block the Phase 2 design.

## What we checked (2026-11-23, documentation only, no code audit)

- Matches the docs: client-side AES-256-GCM, PBKDF2 (600,000 rounds), HKDF.
- Matches the docs: server sees vault id, object sizes, timing and object counts only.
- Matches the docs: the vault key is one bearer string. A read key reads all files and all history.
- Matches the docs: no recovery. Re-key changes the vault id and resets history.
- Matches the docs: merges are whole-file. Reads are open on the shared host.
- Unverified: a Swift client, `sgit share send` status, per-device commit signing, sg-send-cli vs sgit-ai.

## The questions

| # | Topic | Question | Our proposed answer |
|---|---|---|---|
| 1 | Swift client | Is there a Swift or embeddable client? Are the wire format and test vectors stable enough to build against? | Build a small native Swift client: clone, pull, write, commit, push. Apple crypto libraries only. Offer it upstream. |
| 2 | Device revocation | Can a lost device be revoked without re-keying? Is per-device access on the roadmap (RFC 0001)? | Accept re-key for now. Vault is small. Remaining devices get the new key by QR scan. |
| 3 | Key recovery | What recovery flow do you recommend for non-technical users? | No recovery as the base. Rebuild the vault from the phone. Add a printed QR recovery sheet for web viewer users. |
| 4 | Sync conflicts | Can a client resolve merges itself and push a normal merge commit? When does JSON-aware merge ship? | One record per file. Field-level last writer wins. Deletes are tombstones. |
| 5 | Keychain and Secure Enclave | Can SGit verify commits signed by a raw P-256 device key? | Vault key in the Keychain, this device only, wrapped by a Secure Enclave key. A second Secure Enclave key signs commits. |
| 6 | Server metadata | Does padding records break deduplication? What does the server log by default? | Pad to 1 KB steps. Batch pushes with jitter. Own server in single-key mode before real users. |
| 7 | Web viewer | Can we host our own viewer build, or must we use SG/Vault? Would you use a separate viewer vault? | Static viewer, no third-party scripts. Read key by QR or URL fragment. Separate viewer vault with upcoming reminders only. |
| 8 | Rollback | Is there a built-in check against a server handing out an old head? | Devices store the last commit seen and refuse older heads. |
| 9 | Package and version | Which package and version should we pin? | `sgit-ai`, one exact version. |
| 10 | Format stability | What is the vault format versioning policy during beta? | Build against the wire format, not the CLI. Keep a migration test. |
| 11 | Share features | Is `sgit share send` disabled, and when does it return? | Not needed in Phase 2. |
| 12 | Audit | Has SGit had an external security audit? Is one planned? | None assumed. |

## What we need back

- Questions 1 to 4: a decision or correction in the call.
- Questions 5 to 8: a short written answer after the call.
- Questions 9 to 12: a pointer to the right page.
- Anything wrong in "What we checked".
