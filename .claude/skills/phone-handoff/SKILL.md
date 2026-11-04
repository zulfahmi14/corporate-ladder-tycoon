---
name: phone-handoff
description: How to ask the owner (busy, phone-only) to do something - one small step at a time with exact taps, copy-paste values, and a clear reply format. Use whenever a step needs the owner (accounts, secrets, approvals, testing, merging PRs).
---

# Phone handoff

The owner avoids the laptop. Every request must be doable on a phone in
<= 10 minutes.

## Format for each owner step
```
STEP <id>: <goal in one line>  (~N min)
1. Open <app or URL>
2. Tap <exact label> > <exact label>
3. Paste: <value in its own code block>
Reply with: "<exact short reply>" or a screenshot of <screen>.
```
- One step per message when possible; max 3.
- Give exact UI labels; if unsure of current labels, say "look for ..." and
  ask for a screenshot rather than guessing.
- Put copyable values each in their own code block.
- Never ask the owner to run terminal commands, install SDKs, or edit files.
- Secrets: tell the owner exactly where to paste (GitHub secret name) and to
  also save in a password manager; never ask them to send secrets back in chat
  unless no other route exists.
- Approvals: give a 5-line summary + link to the full file/PR.
- After the owner replies, update the Master Plan doc (tick, Facts,
  Decisions) in the same session.
- Merging: give the PR link; owner merges in the GitHub app.
