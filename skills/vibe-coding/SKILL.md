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
6. **No implementation action is allowed until the gate files exist on disk.**
   Implementation actions include: `Bash` commands that install/build/run
   anything outside `.vibe/`, `Write`/`Edit` to any file outside `.vibe/`,
   `flutter create` / `npm init` / `npx create-*` / package installs / git init
   in a non-empty dir / any scaffolding command. Before any such action, you
   MUST verify ALL of these files exist on disk:
     - `.vibe/STATE.md` (phase ≥ 3)
     - `.vibe/requirements.md`
     - `.vibe/architecture.md`
     - `.vibe/conventions.md`
     - `.vibe/tasks/index.json` with at least one task
     - `.vibe/tasks/T###.md` for each task in the index
   If any are missing, STOP and go back to the phase that produces them. Do
   NOT proceed on "implied approval" or because the user sounded ready.
7. **Codex Plan mode's "Yes, implement this plan" is NOT a PHASE 1 or PHASE 2
   gate approval.** Codex App's Plan mode shows its own internal plan summary
   and asks the user to confirm — that confirmation only means "the plan you
   verbally described is acceptable". It does NOT excuse you from:
     (a) actually writing the three `.vibe/*.md` files,
     (b) re-presenting their on-disk contents and pausing for explicit
         PHASE 1 approval,
     (c) writing PHASE 2 task tickets to `.vibe/tasks/`, and
     (d) pausing again for explicit PHASE 2 approval.
   Treat the Plan-mode confirmation as one piece of input feeding PHASE 1,
   nothing more. The two HUMAN GATEs in this skill are separate, explicit, and
   require fresh user messages after the files are on disk.

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
  list 2–3 candidates plus a recommended default. Never output a bare question
  that invites free-form prose when a multiple-choice form would do. The only
  exception: free-text fields that genuinely have no finite option set (e.g.
  project name, target user description).
- **Before asking ANY question, check whether the structured picker tool is
  available in the current session.** If it is NOT available (common case:
  Codex App is in `Default` mode where `request_user_input` is gated off),
  STOP and tell the user in one line:

  > "结构化选项需要 **Plan 模式**(Codex App 右上角切换)。切到 Plan 模式后
  >  重新发我一次刚才的需求,我会用弹窗收集答案。要继续用编号文本也可以,
  >  回复 `继续` 即可。"

  Wait for the user to either switch modes (you'll then see the tool become
  available on next turn) or explicitly opt into text fallback. Do not silently
  degrade — the user must see why the UX dropped to plain text.

- **Use the host's structured-picker tool. Do NOT fall back to plain text if
  the tool exists.** Detection order:
  - **Claude Code** → call `AskUserQuestion` (supports multi-select; client
    auto-adds "Other").
  - **Codex CLI / Codex App (Plan mode)** → call `request_user_input`. Schema
    constraints (enforced by Codex, will reject on violation):
    - `questions`: 1–3 items max per call.
    - Each question needs `id` (snake_case), `header` (≤12 chars),
      `question` (one sentence), `options` (2–3 items).
    - Each option needs `label` (1–5 words) + `description` (one sentence on
      impact/tradeoff). Put the recommended option first and suffix its label
      with `(Recommended)`.
    - Do NOT add an "Other" option yourself — Codex appends a free-form
      "Other" automatically.
    - Set `autoResolutionMs` only for non-blocking questions where best-guess
      defaults are acceptable; omit it for must-answer questions.
  - **Any other CLI** that lacks both tools → fall back to numbered text
    ("reply with the number"), keeping the same enumerated discipline.
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

**Order of operations (do all of these, in order, before PHASE 2):**
  1. Write the three files above to disk now. Do NOT batch them into "I will
     write these once you approve" — write first, ask second.
  2. Also create `.vibe/STATE.md` with `phase: 1` and a short cursor.
  3. Show the user a concise summary of the on-disk contents (a few bullets
     per file is fine) and explicitly say: "三份文档已写入 `.vibe/`,请确认或
     修改。批准后我才会进入 PHASE 2 任务拆分,**这一步还不会写任何代码**。"
  4. WAIT for a fresh user message that approves PHASE 1. A Codex Plan-mode
     plan acceptance from earlier in the conversation does NOT count.
  5. Only after explicit approval, update `.vibe/STATE.md` to `phase: 2` and
     proceed to PHASE 2.

**GATE (PHASE 1):** approval is required and is separate from any Plan-mode
plan confirmation Codex App may have shown.

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

**Order of operations (do all of these, in order, before PHASE 3):**
  1. Write `.vibe/tasks/index.json` and one `.vibe/tasks/T###.md` per task to
     disk now. Do not "draft them in chat" first.
  2. Show the user the task list (id, title, layer, deps) and explicitly say:
     "任务清单已写入 `.vibe/tasks/`。请审阅/重排序/增删,批准后我才会动手实
     现。**这一步还不会跑 `flutter create`、`npm install` 或任何脚手架命令。**"
  3. WAIT for a fresh user message approving the task list.
  4. Only then update `.vibe/STATE.md` to `phase: 3` and start PHASE 3.

**GATE (PHASE 2):** approval is required. Re-using a Plan-mode confirmation or
treating PHASE 1 approval as covering PHASE 2 is a hard rule violation.

---

## PHASE 3 — Development loop  (parallel, unattended-capable)

**Entry check — refuse to start PHASE 3 if any of these are false:**
  - `.vibe/STATE.md` exists and its `phase` field is `3`.
  - `.vibe/requirements.md`, `.vibe/architecture.md`, `.vibe/conventions.md`
    all exist and are non-empty.
  - `.vibe/tasks/index.json` exists with at least one task entry.
  - Every task referenced in the index has its own `.vibe/tasks/T###.md` file.
  - The user has, in a fresh message after the task list was written to disk,
    explicitly approved PHASE 2.

If any check fails, STOP and return to the phase that produces the missing
artifact. Do NOT run any installer, scaffolder, or build command before all
checks pass.

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
