# T###  —  <short title>

- **layer**: shared | backend | frontend | infra
- **deps**: [T001, T002]        # task ids that must be `done` first ([] if none)
- **outputs**:                  # files this task creates or modifies
  - path/to/file.ts

## Description
What to build, precisely enough that an isolated sub-agent with no other context
could implement it. Include relevant interface/contract details from deps.

## Acceptance criteria (human-readable)
- [ ] Criterion 1 (observable behavior, not "code written")
- [ ] Criterion 2

## Verify (commands that decide pass/fail)
```
# e.g.
npm run build
npm test -- <relevant test>
# UI tasks: add a visual check, e.g. a Playwright screenshot step
```

## Resume notes (filled by orchestrator if interrupted)
<!-- If this task was reset from in_progress to todo, describe what partial work
     already exists so it isn't blindly redone. -->
