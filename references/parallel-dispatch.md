# Parallel Dispatch (PHASE 3)

## When two tasks may run in parallel
BOTH must be true:
1. **No dependency** between them (neither is in the other's `deps`, directly or
   transitively).
2. **Disjoint outputs** — the `outputs` file sets do not overlap. If both touch
   the same file, run them serially even if otherwise independent.

If unsure, serialize. A wrong merge costs more than a slow run.

## Why contract-first makes parallelism safe
The contract tasks (shared types, DB schema, API spec) are completed and `done`
FIRST. Once the interface between front-end and back-end is frozen on disk, a
front-end sub-agent and a back-end sub-agent can build against the same contract
simultaneously without guessing each other's shape.

## Sub-agent brief (must be self-contained)
Sub-agents run in fresh, isolated context and share nothing but the filesystem.
Each brief includes ONLY:
- The full text of the target task file (`.vibe/tasks/T###.md`).
- `.vibe/architecture.md` and `.vibe/conventions.md`.
- The contract/output files of every task in this task's `deps`.
- The instruction: implement exactly this task, create the files listed in
  `outputs`, then run the `verify` commands and report pass/fail with output.

Do NOT tell a sub-agent to "continue from before" or reference other agents —
they have no shared memory. Everything it needs is in the brief.

## Orchestrator responsibilities around a parallel batch
1. Before dispatch: set each task `in_progress` in index.json, append to
   progress.log.
2. Dispatch the batch.
3. Collect results. For each: run/confirm verify, then set `done` or, on repeated
   failure, `blocked` with the reason.
4. Update STATE.md resume cursor.
5. Recompute the runnable frontier and loop.

## Host capability detection
- Claude Code: use the Task tool to spawn sub-agents.
- Codex CLI: dispatch parallel agents per its mechanism.
- No sub-agent support (plain chat): ignore all of the above and process the
  runnable frontier one task at a time, in dependency order.

## Failure isolation
A blocked or failed task must not corrupt sibling tasks in the batch. If a
parallel task fails, still collect and finalize the others, then surface the
failure. Never leave a task stuck at `in_progress` — the resume reconciliation
relies on accurate status.
