# Resuming in a graphical chat app (no filesystem)

Graphical chat apps (phone / web chat) have no persistent filesystem, so the
`.vibe/` directory can't live there. You have two honest options.

## Option A (recommended): keep the project in a CLI tool
Run the actual project in Codex CLI or Claude Code, where `.vibe/` persists and
sub-agents work. Use the chat app only for thinking/planning. This is the only
way to get true seamless resume + parallelism.

## Option B: single-session mode in the chat app
If you must work entirely in the chat app:
- The skill keeps the requirements doc, task list, and statuses inline in the
  conversation instead of on disk.
- There are no sub-agents, so PHASE 3 runs one task at a time.
- To resume in a NEW conversation, the user pastes the last known state back in.

### Startup prompt the user pastes to resume in a new chat
Tell the user to copy their latest state block (the requirements summary + the
task table with statuses) and prepend this:

```
Resume my vibe-coding project. Below is the saved state from my last session:
the requirements summary and the task table with each task's status. Read it,
tell me which task is next (first `todo` whose deps are all `done`), then
continue the development loop from there. Do not restart from scratch.

--- SAVED STATE ---
[paste requirements summary + task table here]
--- END SAVED STATE ---
```

The reliability of Option B depends entirely on the user keeping that state
block up to date. Encourage them to copy the refreshed task table out of the
chat whenever they stop. This is a real limitation of chat-only environments,
not a bug — there is no disk to remember for them.
