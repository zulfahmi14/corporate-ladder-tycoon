---
name: token-economy
description: Rules for keeping Claude sessions short and cheap on this repo - targeted reads, no re-reading, small diffs, script-generated tables, terse replies. Use in every long or repetitive session.
---

# Token economy

## Reading
- Start from the Master Plan doc **Now** section only (read the doc outline, then
  that section; never the whole doc).
- Use `grep -n` / `rg` to locate, then read only the line range needed.
- Never re-read a file you just wrote or edited.
- Do not dump generated files, lockfiles, `.import`, `.tscn` bulk or CI logs;
  `tail -50` logs and grep for `error|FAIL`.
- Load only the one skill the step needs.

## Writing
- Prefer small targeted edits over rewriting files.
- Generate repetitive content (upgrade tables, translations skeleton,
  balance curves) with a script in `tools/` and commit the script + output;
  regenerate instead of hand-editing.
- Keep data in compact CSV/JSON tables, not prose.
- Batch independent tool calls in one turn.

## Replies to the owner
- Phone-readable: result first, max ~10 lines, then the next owner step.
- No restating the plan or the code; link the file/PR instead.
- Do not narrate options you will not pursue.

## Long sessions
- Record decisions in the plan (Decisions/Facts) as they happen so a
  compacted or new session does not need to re-derive them.
- Use subagents only when the owner asks; they start cold and cost more.
