# Ideas backlog

Ideas for later phases. Not in Phase 1 scope unless the conductor moves them there.
Owner for build: developer. Owner for review: security-vault.
Items marked "verify" must be checked against current Apple documentation before build.

## I-1. Siri access

### Goal
- The user can talk to the PA through Siri, hands free.
- Example phrases (X = app name):
  - "Hey Siri, ask X what I need to remember later today."
  - "Hey Siri, ask X what my next meeting is."
  - "Hey Siri, ask X what's next."

### How it could work
- Apple's App Intents framework exposes app actions to Siri, Shortcuts and Spotlight. (verify)
- App Shortcuts let the app ship spoken phrases that work with no user setup. The phrase must include the app name. (verify)
- Siri itself cannot be renamed. The wake phrase stays "Hey Siri" (or "Siri"). The app name goes in the command.
- Newer Apple Intelligence Siri may call app actions from looser phrasing, without a fixed phrase. (verify version and limits)
- Answers come from the PA's local store. No network needed.

### Why it beats plain Siri
- Siri can already read the calendar.
- The PA answers from cross-checked data: calendar, email bookings, screenshots, reminders.
- Example: "Your flight is at 18:00 today. It came from an email and is not in your calendar. Add it?"

### Candidate intents
- What's next
- What do I need to remember today
- My next meeting
- Anything I've missed (open conflicts)
- Add this (dictated reminder, parsed like a screenshot)

## I-2. Learned reminder timing

### Goal
- The PA learns when reminders are most useful to this user, then times them to suit.

### How it could work
- Record on device only: when each alert was shown, opened, snoozed, acted on or ignored.
- Learn per type of reminder (travel, bills, meetings, birthdays) and per time of day.
- Start with simple rules and statistics. Use the on-device model only if rules fall short.
- Hard limits always apply: travel and deadline alerts never move later than a safe cut-off.
- User can see and reset what was learned.

## I-3. Autonomous proactive scanning

### Goal
- The PA looks through connected sources on its own and finds what the user missed.
- Example: an email about a flight tonight at 18:00 that is not in the calendar.

### How it could work
- Background refresh scans new items from approved sources only. (verify background task limits)
- Same pipeline as screenshots: extract, cross-check, decide.
- Output goes through calm notification ranking. Few alerts, high value.
- All processing on device. Each source needs the user's explicit opt-in.
- Security: email content is untrusted. Same prompt injection rules as screenshots. Email access is a network call and needs security-vault approval.

## I-4. Live Activities

### Goal
- Time-critical items show live on the Lock Screen and in the Dynamic Island.
- A strong UI and UX moment for the brand.

### Candidate uses
- Travel day: countdown to leave, check-in opens, gate, boarding.
- Next meeting: time left, place, travel time.
- Deadline day: time left, one-tap done.
- Conflict found: "Ticket says the 18th, calendar says the 19th. Fix?"

### How it could work
- ActivityKit for Live Activities, with a WidgetKit extension for the views. (verify)
- Start and update from the app on device. No remote push in the first version, because push needs a server (security gate).
- Design work: graphic-design leads the visual language once the name and logo exist.

### Privacy notes
- The Lock Screen is visible to anyone holding the phone.
- Default to minimal detail. Let the user choose how much shows when locked.

## Open points
- Which phase each idea lands in. Suggested: I-1 and I-4 late Phase 1 or early Phase 2. I-2 and I-3 Phase 2.
- security-vault to review Siri responses on a locked phone and Lock Screen exposure.
