# `.vibe/` State Specification

This is the single source of truth for a project. Any agent can resume by
reading these files. Keep them in the project root under `.vibe/`.

```
.vibe/
├── STATE.md            # current phase + resume cursor + autonomy level
├── requirements.md     # PHASE 1 output: business + scope
├── architecture.md     # PHASE 1 output: architecture + tech selection + why
├── conventions.md      # PHASE 1 output: code style
├── progress.log        # append-only audit log (one line per action)
├── acceptance-report.md# PHASE 4 output
└── tasks/
    ├── index.json      # the task table (status lives here)
    ├── _TEMPLATE.md    # task file template
    └── T001.md ...     # one file per task
```

## STATE.md

Human-readable, but keep the front block machine-parseable:

```markdown
---
phase: 3                # 1 | 2 | 3 | 4
autonomy: auto          # supervised | auto
resume_cursor: T014     # next task to attempt, or "-" if none
updated: 2026-06-23T10:30:00Z
---

# Resume notes
Free-form notes for the next agent: anything subtle about where we stopped,
decisions pending, environment quirks.
```

## tasks/index.json

The status of every task lives ONLY here (task .md files hold the spec, not the
live status — avoids two sources of truth). Schema:

```json
{
  "project": "my-app",
  "tasks": [
    {
      "id": "T001",
      "title": "Define shared API types",
      "layer": "shared",
      "status": "done",
      "deps": [],
      "outputs": ["src/types/api.ts"]
    },
    {
      "id": "T014",
      "title": "Build login form",
      "layer": "frontend",
      "status": "todo",
      "deps": ["T001", "T009"],
      "outputs": ["src/components/LoginForm.tsx"]
    }
  ]
}
```

`status` ∈ `todo | in_progress | done | blocked`.
`layer` ∈ `shared | backend | frontend | infra`.

## progress.log

Append-only, one line per event. Never rewrite. Format:

```
2026-06-23T10:31:02Z  T014  in_progress  dispatch (serial)
2026-06-23T10:36:40Z  T014  done         verify passed: npm test -- LoginForm
2026-06-23T10:36:41Z  T015  blocked      needs STRIPE_API_KEY from user
```

## Reconciliation rule (on resume)

For each `in_progress` task: check its `outputs` exist AND its `verify` passes.
- pass → flip to `done`
- otherwise → flip to `todo` and add a resume note in its task file describing
  what partial work exists, so it isn't blindly redone.
