# AI PA: multi-agent starter folder

## Setup (5 minutes)
1. Unzip this folder somewhere on your computer.
2. Optional: run `git init` here, so every change is tracked.
3. Open five terminal windows, each in this folder.
4. In each one, run `claude` to start a Claude Code session.
5. In each session, type `/model` and pick Claude Fable 5.2 for the first prompts. Switch to Opus 5.5 later the same way.
6. Paste the matching starting prompt:
   - Window 1: agents/conductor/PROMPT.md
   - Window 2: agents/creative-vision/PROMPT.md
   - Window 3: agents/graphic-design/PROMPT.md
   - Window 4: agents/developer/PROMPT.md
   - Window 5: agents/security-vault/PROMPT.md
7. Tip: name each session so they stay organised, for example with `/rename conductor` if your version supports it.

## How agents talk
They write message files into each other's inbox under comms/. Rules are in CLAUDE.md.
Agents do not watch inboxes live. When one agent sends a message, tell the receiving session: "Check your inbox."

## Requirements
- The developer agent needs a Mac with Xcode to build and run the iOS app.

## Order of work
1. creative-vision produces names (its brief is already in its inbox).
2. You pick a name with the conductor.
3. The conductor sends the name to graphic-design.
4. graphic-design produces 5 logo concepts.

In parallel:
- developer builds Phase 1, milestone by milestone.
- security-vault writes the threat model and approves every permission the developer requests.
