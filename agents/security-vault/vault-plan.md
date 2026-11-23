# AI PA vault plan: SGit in Phase 2

- Owner: security-vault agent
- Version: 0.1 (2026-11-23)
- Status: proposal. Dinis Cruz's decisions are final on vault design.
- Related: [threat-model.md](threat-model.md), vault brief linked in [docs/links.md](../../docs/links.md)

## 1. Summary

- SGit fits the core promise. The server stores ciphertext only. Verified against sgit.ai.
- Four findings change the brief's assumptions:
  1. No Swift or iOS client is documented. We must build or embed one.
  2. A vault key is a shared bearer key. There is no per-device revocation. Revoking means re-keying, which changes the vault id and resets history.
  3. There is no key recovery by design. Our app must supply it.
  4. Merges are whole-file. JSON-aware merge is not shipped. Our file layout must avoid conflicts.
- None of these block Phase 2. Each needs a decision from Dinis.
- Phase 1 needs nothing from the vault. It should only keep its record format sync-ready.

## 2. What was verified

- Checked on 2026-11-23.
- Sources read: pypi.org/project/sg-send-cli, pypi.org/project/sgit-ai, sgit.ai (home, security model, credentials, key management, limitations, API authentication, append lanes, exposed-key runbook, self-hosting), via sgit.ai/llms-full.txt.

| # | Claim | Status | Source |
|---|---|---|---|
| V1 | Client-side AES-256-GCM. 12-byte IV, 16-byte tag. | Verified | sgit.ai/security |
| V2 | Key derivation: PBKDF2-HMAC-SHA256, 600,000 rounds. HKDF-SHA256 for per-file keys. | Verified | sgit.ai/security |
| V3 | Server never sees content, filenames, commit messages, branch names or keys | Verified (as documented, not audited by us) | sgit.ai/security |
| V4 | Server does see: vault id, object sizes, read and write timing, object counts | Verified | sgit.ai/security |
| V5 | Vault key format `passphrase:vault-id`. One string is address, credential and encryption root. About 124 bits of entropy. | Verified | sgit.ai/security, docs/what-is-sgit |
| V6 | Read key is derived one-way from the vault key. It cannot write. | Verified | sgit.ai/docs/credentials |
| V7 | A read key reads every file and every past commit | Verified | sgit.ai/docs/credentials |
| V8 | Rotation is not retroactive. Old fetched objects stay readable with the old key. | Verified | sgit.ai/docs/credentials, key-management |
| V9 | No password reset and no recovery | Verified | sgit.ai/security, docs/limitations |
| V10 | Re-key resets history to one commit and changes the vault id. The old vault must be deleted on the server to kill the old key. | Verified | sgit.ai/case-studies/exposed-vault-key |
| V11 | Server stores SHA-256 hashes of capability keys, not the keys | Verified | sgit.ai/api/authentication |
| V12 | On the shared host, vault reads need no authentication. Anyone with the vault id can fetch ciphertext. | Verified | sgit.ai/api/authentication |
| V13 | Three-way merge is whole-file. JSON-aware merge is designed, not shipped. | Verified | sgit.ai/docs/limitations |
| V14 | CLI and browser (SG/Vault) are separate implementations of one wire format with test vectors. Web Crypto compatible. | Verified | sgit.ai/security |
| V15 | PKI: RSA-OAEP 4096 and ECDSA P-256. No revocation, expiry or rotation workflow. | Verified | sgit.ai/docs/pki, limitations |
| V16 | Licence Apache-2.0. Two runtime dependencies. Beta. | Verified | PyPI sgit-ai, sgit.ai |
| V17 | Self-hosted SG/Send server exists (Docker image, access token gates all routes in single-key mode) | Verified as documented | sgit.ai/docs/self-host-for-agents |
| V18 | A Swift or iOS client exists | Not found in any source read. Treat as "does not exist". Unverified until Dinis confirms. | n/a |
| V19 | `sgit share send` is disabled in recent versions (from the brief) | Unverified. Not found in the docs read. | n/a |
| V20 | sg-send-cli is the current package | Likely outdated. PyPI shows sg-send-cli 0.8.15. Its GitHub README now describes `sgit-ai` (PyPI 0.27.0). Relationship unverified. | PyPI |
| V21 | Per-device signed commits work today | Conflicting. The sgit-ai PyPI page documents commit signing with SSH or OpenPGP keys. The limitations page says author attribution is "planned". Unverified. | PyPI, sgit.ai/docs/limitations |
| V22 | The "structure key" split protects metadata from read-key holders | Not active yet, per the security page | sgit.ai/security |
| V23 | Our own audit of SGit code or crypto | Not done. All "verified" rows mean "matches current documentation". | n/a |

- Version note: the docs cite several versions (0.15 to 0.32). PyPI shows sgit-ai 0.27.0. Pin an exact version before building.

## 3. Proposed Phase 2 design

### 3.1 Principles

- Raw data never leaves the iPhone. Only derived records sync.
- The SGit client is the single exit point for user data.
- One vault per user. Small JSON files.
- The web viewer holds a read key only.

### 3.2 What syncs and what never syncs

| Syncs (derived records) | Never syncs |
|---|---|
| Events: title, start, end, place | Screenshots and photos |
| Tasks and reminders | Emails and PDFs |
| Bookings: type, date, reference | OCR text and model prompts |
| Conflict flags and their status | Email tokens and any key |
| User settings | "Info to remember" notes, unless the user opts in per note |
| Device list (names, public keys) | Correction history |

- A written schema lists every synced field. The sync code refuses fields not on it.

### 3.3 Vault layout

- One record per file. This keeps whole-file merges safe (V13).
- Proposed tree:
  - `records/<kind>/<uuid>.json`
  - `tombstones/<uuid>.json`
  - `devices/<device-id>.json`
  - `settings.json`
- Every record carries: `id`, `kind`, `updated_at`, `updated_by` (device id), `schema_version`.
- Records are padded to fixed size buckets before encryption. See Q7.
- Each device uses its own private clone branch and merges into one shared branch. This matches SGit's two-branch model.

### 3.4 Data flow

1. The phone's reasoning layer writes a record to the local store.
2. The sync layer copies allowed fields into the vault folder.
3. The Swift client encrypts, commits and pushes. Only changed ciphertext travels.
4. Other devices pull, verify, decrypt and merge.
5. Each device schedules its own local notifications from the records.
6. The web viewer clones with the read key and decrypts in the browser.

- Notifications: no reminder text goes through Apple's push service. A silent "please sync" push with no content is a later option and a security gate item.

### 3.5 Server choice

- Option A: shared SG/Send host. Fast start. Reads are open to anyone who knows the vault id (V12).
- Option B: our own SG/Send server in single-key mode. The access token gates reads too. More work to run.
- Proposal: A for a prototype, B before real users. For Dinis.
- Any server is a network service. It needs a security gate approval before the developer wires it in.

## 4. Open questions and proposed answers

### Q1. Is there a Swift or embeddable client, or do we build one?

- Finding: none documented (V18).
- Options:
  - A. Native Swift client for a small subset: clone, pull, write, commit, push. Uses CryptoKit (AES-GCM, HKDF) and CommonCrypto (PBKDF2). Tested against SGit's published wire-format test vectors. No third-party dependencies.
  - B. Embed the Python CLI in the app. Large, fragile, hard to review.
  - C. Run the browser client's JavaScript inside the app. Wider attack surface. Key handling in a script engine.
- Proposed answer: A. It keeps the crypto in Apple's libraries and the dependency count at zero.
- For Dinis: confirm no Swift client exists. Confirm the wire-format contract and test vectors are stable enough to build against. Say whether he wants the Swift client upstream in the SGit project.

### Q2. How do vault keys map to the Keychain and Secure Enclave?

- Fact: the Secure Enclave holds only P-256 private keys. It cannot hold a symmetric vault key or a passphrase.
- Proposed answer:
  - Store the vault key as a Keychain item. Accessibility: AfterFirstUnlockThisDeviceOnly if background sync is needed, otherwise WhenUnlockedThisDeviceOnly.
  - Wrap it with a Secure Enclave P-256 key, so the stored item is useless off the device.
  - Each device also has a Secure Enclave P-256 signing key for commits. ECDSA P-256 matches SGit's PKI (V15).
  - Derived keys live in memory only. Never written to disk.
  - The vault key is never displayed after setup, never logged, never in a URL.
- For Dinis: confirm SGit can verify commit signatures made by a raw P-256 device key, not only SSH or OpenPGP keys (V21).

### Q3. What is the key recovery flow for non-technical users?

- Finding: SGit has no recovery (V9). The app must provide it.
- Options:
  - A. Recovery sheet. At setup the app shows a QR code and words to print or save. Restore by scanning it. Nothing goes to any server.
  - B. iCloud Keychain sync of the vault key. Easy. Recovery follows the Apple account. The key then leaves the device under Apple's end-to-end encryption.
  - C. No recovery. A new vault is rebuilt from the phone's local data.
- Proposed answer: C as the base, because the phone is the source of truth and the vault holds only derived copies. Add A for users with a web viewer or a second device. Offer B only as a clear opt-in.
- For Dinis: his recommended flow. Whether `sgit vault backup --include-key` has a role on mobile.

### Q4. How do we revoke a lost device without re-keying everything?

- Finding: today we cannot. Every device holds the same bearer key. The documented remedy is delete on server, re-key, push (V10).
- Why re-key is acceptable for us:
  - The vault is small. Re-encrypting takes seconds.
  - Losing history costs little. The phone holds the truth.
- Costs:
  - The vault id changes. Every other device and the web viewer need the new key.
  - Data the lost device already holds stays readable on it (V8). iOS Data Protection and remote wipe are the real defence there.
- Proposed answer:
  - "Remove a device" in the app runs: delete old vault on server, re-key, push, verify the old key fails.
  - Remaining devices get the new key by scanning a QR code from the phone that did the re-key.
  - The web viewer gets a new read key the same way.
  - Signed commits from the removed device are rejected from that point.
- For Dinis: is per-device access on the roadmap (for example the public-key RFC 0001)? Is a design with one vault per device plus append lanes better here?

### Q5. How are sync conflicts handled when two devices edit the same reminder?

- Finding: whole-file three-way merge. Conflicts produce conflict files (V13).
- Proposed answer:
  - One record per file, so two devices rarely touch the same file.
  - The Swift client resolves same-file conflicts itself, in code: field-level last-writer-wins on `updated_at`, with device id as tie-break.
  - Deletes are tombstones, so a delete is never undone by an old edit.
  - "Done" beats "not done" for tasks. A resolved conflict flag stays resolved.
  - The user never sees a conflict file.
  - Clock skew: reject records dated more than a day in the future.
- For Dinis: can a client resolve merges itself and push a normal merge commit? When does JSON-aware merge ship?

### Q6. Share features (`sgit share send`) are disabled. Do we need them?

- Finding: could not verify the disabled status (V19).
- Proposed answer: not needed for Phase 2. One user, own devices, one vault. Sharing with other people (family calendars) is a later phase and would use read keys or the PKI layer.
- For Dinis: current status and plans, for the record.

### Q7. What metadata is visible to the server?

- Verified (V4, V12): vault id, encrypted object sizes, timing of reads and writes, object counts. IP addresses reach any server too (our inference, not from the docs).
- What this reveals: when the user is active, how busy their life is, roughly how many records change.
- Proposed answer:
  - Pad each record to a fixed bucket (for example 1 KB steps) before encryption.
  - Batch pushes. Sync on a schedule with jitter, not at the moment of each change.
  - Run our own server in single-key mode before real users, so strangers cannot fetch ciphertext or watch activity.
  - Keep minimal server logs. Publish what is logged.
  - Say the remaining metadata plainly in the privacy policy.
- For Dinis: does padding break deduplication or anything else? Any server-side log retention defaults?

### Q8. Can a browser decrypt a read-only clone safely?

- Verified: yes in mechanism. The SG/Vault browser client is an independent implementation using Web Crypto (V14). Read keys cannot write (V6).
- Risks:
  - The page's JavaScript is a trust root. Whoever serves it could steal the read key.
  - A read key opens all files and all history (V7). The metadata split is not active (V22).
  - A leaked read key cannot be pulled back. Only future data is protected by re-keying (V8).
  - Cross-site scripting or a browser extension can read decrypted data.
- Proposed answer:
  - Viewer is a static site with no third-party scripts, strict Content Security Policy and Subresource Integrity.
  - The read key arrives by QR scan or URL fragment, never in a query string or server log.
  - Keep the key in memory by default. "Remember this browser" is opt-in and uses a non-extractable Web Crypto key.
  - Keep history short. Periodic re-key (for example every 90 days) trims what a leaked read key can open.
  - Sync less to the viewer vault if needed: a separate, smaller "viewer" vault holding only upcoming reminders.
- For Dinis: can we host our own viewer build against the wire format, or must we use SG/Vault? Is a separate viewer vault the pattern he would recommend?

### Extra questions found during this review

| # | Question | Proposed answer |
|---|---|---|
| Q9 | Which package and version do we build against? (V20) | `sgit-ai`, exact pinned version. For Dinis to confirm. |
| Q10 | Rollback protection. Can a server hand a device an old head? | Devices store the last seen commit and refuse older heads. Signed commits. For Dinis: is there a built-in check? |
| Q11 | Has SGit had an external security audit? | Unknown. The site mentions an internal review series. For Dinis. |
| Q12 | Format stability. SGit is beta and commands can change. | Build against the wire format, not the CLI. Keep a migration test. For Dinis: format versioning policy. |

## 5. What Phase 1 should do now to be ready

- Give every record a UUID, `updated_at`, `schema_version` and a source tag.
- Keep raw inputs and derived records in separate stores.
- Use tombstones for deletes from day one.
- Add no sync code and no network code for the vault in Phase 1.

## 6. Security gate for Phase 2

- These need a written "approved" message before work starts:
  - The SG/Send server host and its configuration.
  - The Swift vault client and any package it uses.
  - The web viewer host, its build and its headers.
  - Any push notification service.
- Security-vault will write a Phase 2 review plan once Dinis has answered Q1 to Q8.

**Questions**

These are for the user and conductor. Questions for Dinis are marked "For Dinis" in section 4.

1. Recovery (Q3). Which base approach do you prefer?
   - Option A: printed or saved recovery sheet with a QR code. Nothing stored on any server.
   - Option B: iCloud Keychain sync of the vault key. Easiest. Relies on the Apple account.
   - Option C: no recovery. The vault is rebuilt from the phone if the key is lost. (My recommended base, with A added for web viewer users.)
2. Server (section 3.5). Which do you want?
   - Option A: shared SG/Send host. Fast to start. Ciphertext is fetchable by anyone who knows the vault id.
   - Option B: our own SG/Send server with an access token on every route. More to run, less metadata exposure.
   - My recommendation: A for a prototype only, B before real users.
3. Has Dinis seen the vault brief yet? If you want, I can turn the "For Dinis" items into a one-page question list for the 60 minute review call.
