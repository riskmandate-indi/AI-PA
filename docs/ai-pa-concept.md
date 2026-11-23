# AI Personal Assistant (PA): Concept and Implementation Plan

## 1. The Problem

- People manage their lives across many disconnected apps.
- Details slip through the gaps.
- Example: a flight was entered in the calendar on the 19th instead of the 18th. The flight was missed.
- A human PA would have caught this. Most people cannot afford one.

## 2. The Idea

- A digital PA that sees everything involved in planning a person's life.
- It cross-checks information and tells the user what is next and what to do.
- Everything useful becomes a well-timed notification. No bombarding.

## 3. Core Principles

| Principle | What it means |
|---|---|
| On-device first | AI runs on the phone or laptop. Nothing personal is processed on a server. |
| Encrypted by default | Anything that must leave the device goes into an encrypted vault. |
| User-controlled access | The user chooses exactly which sources the PA can see. |
| Available everywhere | Native apps plus a web app, so reminders reach every device. |
| Calm notifications | Few, timely, actionable alerts. Not a stream of noise. |

## 4. Data Sources

- Calendars (Apple, Google, Outlook)
- Emails, including PDF attachments (tickets, bookings, invoices)
- Diary and notes
- Messages, including WhatsApp
- Reminder and task apps (Apple Reminders, Microsoft To Do, Google Keep or Google Tasks)
- Key dates and events (birthdays, renewals, deadlines, travel)

## 5. Architecture

### 5.1 On-device AI layer
- iOS, iPadOS, macOS: Apple Foundation Models framework.
  - Gives apps access to the on-device model behind Apple Intelligence.
  - Supports summarisation, structured data extraction and tool calling.
  - Free to use. No cloud inference costs.
  - Requires recent hardware (iPhone 15 Pro or later, Apple silicon iPad or Mac).
- Android: on-device model equivalent (to be researched).
- Web: either a browser-run local model or the web app acts only as a viewer of results produced on the user's device.

### 5.2 Connector layer (the "API machine")
- One connector per source. Each connector pulls data into a single local store.
- Data is normalised into one format: events, tasks, bookings, deadlines.

### 5.3 Reasoning layer
- Extracts facts (e.g. flight date from a booking PDF).
- Cross-checks facts across sources (email date vs calendar date).
- Flags conflicts, gaps and upcoming actions.

### 5.4 Encrypted vault layer
- Used only for data that must sync between devices or touch the internet.
- Candidate: Dinis Cruz's SGit and SG/Send vaults.
  - SGit is open source encrypted git (Apache-2.0).
  - Zero-knowledge: the server never sees plaintext.
  - Encryption and decryption happen locally with AES-256-GCM.
  - Supports read-only keys, which suit a viewer-only web app.

### 5.5 Notification layer
- Pushes reminders to all devices.
- Writes back into the user's own reminder apps where possible.
- Ranks alerts by urgency so only important items interrupt the user.

## 6. Integration Feasibility

| Source | Access route | Feasibility |
|---|---|---|
| Apple Calendar and Reminders | EventKit, on device only | High (Apple devices) |
| Google Calendar, Gmail | Google APIs with OAuth | High |
| Outlook, Microsoft To Do | Microsoft Graph API | High |
| Google Tasks | Google Tasks API | High |
| Google Keep | API limited to Workspace accounts | Low for personal users |
| PDFs in email | Download attachment, parse on device | High |
| WhatsApp personal chats | No official API for personal chat history | Low. Workarounds needed |

### WhatsApp workarounds (to evaluate)
- User shares a chat or message into the app via the share sheet.
- User exports a chat manually.
- Android only: read incoming notification text with user permission.
- Avoid unofficial third-party WhatsApp APIs. They break the on-device privacy promise.

## 6A. Decisions Made

- Platform for Phase 1: iOS only.
- Message capture: user screenshots, then shares into the app. No manual typing.

## 6B. Screenshot Capture Workflow ("Share and Forget")

### Goal
- Any screenshot becomes an action with zero taps after sharing.
- Works for any app: WhatsApp, iMessage, email, Instagram, a poster, a ticket.

### User steps (3 taps total)
1. Take a screenshot.
2. Tap Share.
3. Tap the PA app icon.

### What happens automatically
1. A small share pop-up opens and closes by itself after a brief "Got it" tick.
2. On-device text recognition (Apple Vision framework) reads the text in the image.
3. On-device AI (Foundation Models) works out what the content is:
   - Event (dinner, meeting, party)
   - Deadline or bill
   - Task or reminder
   - Travel booking
   - Information to remember (address, code, contact)
4. The PA extracts details: title, date, time, place, people.
5. The PA cross-checks against the calendar and other sources.
6. The PA creates the calendar event or reminder.
7. A notification confirms the result with an Undo option.

### Example
- Screenshot text: "Dinner at 9pm on Wednesday the 15th of August."
- Check: 15 August 2026 is a Saturday, not a Wednesday.
- PA response: "Dinner saved. The message says Wednesday but the 15th is a Saturday. Which is right?"
- This is the same protection as the missed-flight case.

### Adaptability requirement (any photo, no "error occurred")
- Input can be any photo: a chat, a flyer, a poster, a ticket, a handwritten note, a diagram.
- The AI must not expect a calendar layout. It reads the whole image and infers intent.
- If no text exists, it uses visual understanding (layout, symbols, objects).
- It never fails silently or shows a generic error. Fallback ladder:
  1. Clear event found: save it, confirm with Undo.
  2. Partial details (e.g. date but no time): save a draft, ask one short question.
  3. Nothing actionable: save the photo as a searchable note and say what it saw.
- It learns from corrections: when the user edits a result, that correction informs future reads.
- Photos only for now. Other media types come later.

### Technical notes (to verify during build)
- Built as an iOS Share Extension.
- Share extensions have tight memory and time limits.
- Safer design: the extension saves the image to a shared App Group folder, then the main app processes it in the background.
- Everything stays on device. No image is uploaded.

## 7. Example Workflow: The Missed Flight

1. Booking confirmation email arrives with a PDF ticket.
2. PA extracts on device: flight number, date 18th, departure time.
3. PA reads the calendar and finds the flight entered on the 19th.
4. Conflict detected.
5. Notification: "Your flight ticket says the 18th. Your calendar says the 19th. Fix it?"
6. User taps fix. Calendar is updated.
7. Timed reminders follow: check in, leave for the airport, gate info.

## 8. Build Roadmap

### Phase 1: Proof of concept (Apple only)
- Native iOS app.
- Connect Apple Calendar, Apple Reminders and one email account.
- On-device extraction of bookings from emails and PDFs.
- Conflict detection and local notifications.
- Screenshot share extension with automatic processing.

### Phase 2: Cross-platform sync
- Add SGit or SG/Send encrypted vault for device sync.
- Add Google and Microsoft connectors.
- Launch a web app as a secure viewer and reminder hub.

### Phase 3: Wider coverage
- Android app.
- Messaging inputs (WhatsApp workarounds).
- Smarter prioritisation and daily briefings.

## 8A. Ideas for later

- Siri access, learned reminder timing, autonomous scanning and Live Activities.
- Full detail: docs/ideas.md

## 9. Risks and Open Issues

- On-device model is small. Complex reasoning may be limited.
- Older devices cannot run Apple Intelligence.
- A web app cannot run Apple's model. Needs its own privacy design.
- WhatsApp and Google Keep access are restricted.
- Email access permissions (Google and Microsoft) require app verification and security reviews.
- Notification fatigue must be designed against from day one.
