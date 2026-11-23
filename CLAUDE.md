# AI PA Project: shared rules for all agents

## Product
An on-device AI personal assistant (PA) app. iOS first, later web and Android.
It reads calendars, emails, PDF tickets, reminders and screenshots, cross-checks them and alerts the user.
Values: privacy (AI runs on the phone), calm, reliability, foresight, care.
Full concept: docs/ai-pa-concept.md
Existing materials: docs/links.md

## Agents
- conductor: plans, assigns and reviews work
- creative-vision: naming
- graphic-design: logo and brand
- developer: Phase 1 iOS app
- security-vault: threat model, SGit vault, security reviews (works with Dinis Cruz)
Each agent's starting prompt is in agents/<agent>/PROMPT.md

## Folder layout
comms/<agent>/inbox/      messages TO that agent
comms/<agent>/archive/    messages already handled
agents/<agent>/           that agent's work and outputs
docs/                     shared reference documents (conductor edits these)

## Messaging protocol
- At session start and after every task, read comms/<your-agent>/inbox/.
- Move handled messages to comms/<your-agent>/archive/.
- To message another agent, create a file in their inbox named:
  YYYY-MM-DD-HHMM_<from>_to_<to>_<subject>.md
- Every message starts with:
  ---
  from: <agent>
  to: <agent>
  subject: <short subject>
  status: request | update | done | question
  ---
- Keep messages under 150 words. Link to files instead of pasting them.
- Never edit another agent's folder in agents/.

## Security gate
No agent adds network calls, analytics, third-party SDKs or cloud services without a written "approved" message from security-vault.

## Writing style
No em dashes. Short sentences. Bullet points. End reports with a bold "Questions" section.
When asking the user to choose, list the options in full. Never assume they can scroll back.
