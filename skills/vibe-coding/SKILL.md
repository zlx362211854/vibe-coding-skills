---
name: vibe-coding
description: >-
  End-to-end orchestrator for building a software project from zero. Drives the
  full loop: gather requirements -> write a requirements doc -> split into
  detailed front-end/back-end task tickets with acceptance criteria -> implement
  tasks in dependency order (running independent tasks in PARALLEL via
  sub-agents) -> verify and mark each task done -> final acceptance review. ALL
  state is persisted to a `.vibe/` directory so work survives interruption and
  any agent can resume seamlessly by reading the state files. Use this skill
  WHENEVER the user wants to start a new app/project from scratch, do "vibe
  coding", build an MVP, scaffold a full-stack project, or asks you to take a
  product idea all the way to working code — even if they don't say the words
  "vibe coding". Also trigger when the user asks to RESUME or CONTINUE a project
  that has a `.vibe/` directory.
---

# Vibe Coding Orchestrator

A state-machine that takes a project from idea to working code through six
phases, persisting everything to `.vibe/` so it is fully resumable.

## Hard rules (read first, every time)

1. **State lives on disk, not in the conversation.** Every decision, doc, task,
   and status change MUST be written to `.vibe/`. Never rely on chat history to
   remember progress. This is what makes interruption-resume work.
2. **Two human gates are mandatory** and must NOT be skipped: after PHASE 1
   (requirements) and after PHASE 2 (task breakdown). Stop and get explicit user
   approval before continuing past each. Everything inside PHASE 3 can run
   unattended (subject to the autonomy level the user sets).
3. **Always start by checking state.** See "Entry routine" below. Never assume a
   project is new without checking for `.vibe/STATE.md`.
4. **Verify before marking done.** A task is `done` only after its
   `verify` command(s) pass. "It compiles" is not "it's correct" — for UI tasks
   see the verification rules in PHASE 3.
5. **Contract-first.** The first tasks must define shared types / API schemas /
   interfaces. Implementation tasks depend on them. This is what makes safe
   parallelism possible.

---

## Entry routine (do this on EVERY invocation)

```
IF .vibe/STATE.md does NOT exist:
    -> brand-new project. Go to PHASE 1.
ELSE:
    1. Read .vibe/STATE.md (current phase + resume cursor).
    2. Read .vibe/tasks/index.json.
    3. RECONCILE: for every task with status "in_progress", check whether its
       declared output files exist and its verify command passes.
         - passes  -> set status "done"
         - partial/fails -> reset status to "todo" (roll back the half-done work
           or note it in the task file so the next run knows what to redo)
    4. Print a short status summary to the user (phase, X/Y tasks done, what's
       next, anything blocked).
    5. Jump to the phase named in STATE.md and continue.
```

Read `references/state-spec.md` for the exact file formats before writing any
state for the first time.

---

## PHASE 1 — Requirements gathering  (HUMAN GATE at end)

Goal: produce three documents. Ask questions in small groups, not all at once.
Use the checklist in `references/requirements-checklist.md`. Cover:

### Interaction rules (apply to EVERY question in this phase)

- **Never assume the platform.** Before any other architecture question, the
  FIRST question MUST be the platform/form-factor pick (Web app / Native iOS /
  Native Android / Cross-platform mobile / Mini-program 小程序 / Desktop / CLI /
  Browser extension / Other). Do NOT default to "web app" just because the user
  said "app" — in Chinese contexts "app" routinely means a native mobile app or
  a WeChat mini-program. If the host CLI exposes a structured picker tool (e.g.
  Claude Code's `AskUserQuestion`), use it; otherwise present numbered options
  in text and tell the user to reply with the number.
- **Always present enumerated options, not open prompts.** For every choice the
  user has to make (framework, DB, auth provider, deploy target, styling, etc.),
  list 2–5 numbered candidates plus an "Other (specify)" escape hatch. Never
  output a bare question that invites free-form prose when a multiple-choice
  form would do. The only exception: free-text fields that genuinely have no
  finite option set (e.g. project name, target user description).
- **If the host has a picker tool, use it.** Inside Claude Code, prefer
  `AskUserQuestion` (multi-select + Other) over text. Inside Codex CLI or any
  other tool that lacks a picker, fall back to the numbered-text protocol above
  — but keep the same enumerated-choice discipline.
- **One platform pick gates the rest.** After the platform is chosen, all later
  questions (framework, deployment, auth, storage) must be scoped to that
  platform. Do not ask "Vercel or Netlify?" for a native iOS app.

### Coverage

- **Platform / form-factor** (MUST be question #1, see Interaction rules).
- **Business**: target users, core scenarios, MVP scope, explicit non-goals.
- **Architecture**: monolith vs split, deploy target, need for DB / auth /
  realtime / background jobs.
- **Tech selection**: language, framework, UI lib, state mgmt, DB, key
  third-party services. Record *why* each was chosen.
- **Code style / conventions**: naming, directory layout, formatter/linter,
  testing expectations, commit conventions.

Write results to:
- `.vibe/requirements.md`  (business + scope)
- `.vibe/architecture.md`  (architecture + tech selection + rationale)
- `.vibe/conventions.md`   (code style)

**GATE:** Present a concise summary and ask the user to confirm or correct
before PHASE 2. Update `.vibe/STATE.md` to `phase: 2` only after approval.

---

## PHASE 2 — Task breakdown  (HUMAN GATE at end)

Decompose the requirements into tickets. Use the template in
`assets/.vibe/tasks/_TEMPLATE.md`. Rules:

- **Contract tasks first.** Tasks that define shared types, DB schema, and API
  specs get the lowest IDs and are dependencies of everything that uses them.
- Each task MUST have: stable `id`, `title`, `layer` (frontend/backend/shared/
  infra), `description`, explicit `deps` (list of task ids), `outputs` (files it
  will create/modify), `acceptance` (human-readable criteria), and `verify`
  (concrete commands that decide pass/fail).
- Keep tasks small enough to finish and verify independently. If a task can't be
  verified by a command, say so in the file and flag that it needs a human eye.

Write each task as `.vibe/tasks/T###.md` and register all of them in
`.vibe/tasks/index.json` with status `todo`.

**GATE:** Show the task list (id, title, layer, deps) and let the user review /
re-order / add / remove before building. Update `.vibe/STATE.md` to `phase: 3`
only after approval.

---

## PHASE 3 — Development loop  (parallel, unattended-capable)

Repeat until no task is in a runnable state:

1. **Pick the runnable frontier.** A task is runnable if status==`todo` and all
   its `deps` are `done`.
2. **Decide parallel vs serial.** Group runnable tasks. Two tasks may run in
   PARALLEL only if (a) neither depends on the other and (b) their `outputs`
   file sets do NOT overlap. Otherwise run serially. When in doubt, serial.
3. **Dispatch.**
   - If the host supports sub-agents (Claude Code Task tool / Codex parallel
     agents): spawn one sub-agent per parallel task. Give each sub-agent ONLY:
     the task file, `architecture.md`, `conventions.md`, and the contract files
     it depends on. Sub-agents share nothing but the filesystem, so the brief
     must be self-contained — no "continue from before".
   - If no sub-agents (e.g. plain chat app): do the tasks one at a time yourself.
   - See `references/parallel-dispatch.md` for the exact briefing format and
     conflict rules.
4. **Mark `in_progress`** in index.json and append to `.vibe/progress.log`
   BEFORE work starts (so an interruption is recoverable).
5. **Implement**, then run the task's `verify` commands.
   - For backend/logic: run unit tests + build/lint. Pass == done.
   - For frontend UI: build must pass with no console errors; additionally, if
     the verify step includes a visual check, capture it (e.g. Playwright
     screenshot) — do not mark a UI task done on "compiles" alone.
6. **Resolve.** Pass -> status `done`, log it. Fail -> retry up to N (default 2).
   Still failing -> status `blocked`, write the reason into the task file, and
   STOP that task; surface blocked tasks to the user.
7. **Checkpoint cadence.** After each completed task, update STATE.md's resume
   cursor. If `autonomy: supervised`, pause after every batch and report; if
   `autonomy: auto`, only pause on a blocked task, an ambiguity, or an action
   requiring a secret/credential/permission.

When a needed value is missing (API key, DB connstring, a genuine product
decision), do NOT guess — set the task `blocked` with a precise question and ask
the user.

---

## PHASE 4 — Final acceptance review

When all tasks are `done` or `blocked`:

1. Run the whole suite: full build, full test, lint, type-check.
2. For frontend, do an end-to-end pass (screenshots of key screens / a Playwright
   smoke flow) and check against `requirements.md` acceptance items.
3. Produce `.vibe/acceptance-report.md`: what was built, what passed, what's
   still `blocked` and why, and any gaps vs the original requirements.
4. Present it to the user. Do not declare success while items are `blocked`.

---

## Notes on environments

- **CLI (Codex CLI / Claude Code):** full capability — filesystem + sub-agents +
  verify commands all work. This is the ideal home for this skill.
- **Graphical chat app (no filesystem):** you cannot persist `.vibe/`. Operate
  in "single-session" mode: keep the state docs inline in the conversation, and
  to resume in a later session the user must paste the latest state back in. See
  `references/resume-in-chat.md` for the startup prompt to hand the user.
