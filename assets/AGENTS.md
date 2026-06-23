# AGENTS.md

This project is built and maintained using the **vibe-coding** skill.

## For any AI agent working in this repo
- All project state lives in `.vibe/`. **Before doing anything, read
  `.vibe/STATE.md`** to find the current phase and resume cursor, then read
  `.vibe/tasks/index.json` for task statuses.
- Do not restart or re-plan a project that already has a populated `.vibe/`.
  Reconcile and continue per the vibe-coding skill's entry routine.
- Respect the two human gates (after requirements, after task breakdown).
- Verify each task before marking it `done`; never mark `done` on "it compiles"
  alone for UI tasks.

If the vibe-coding skill is installed, trigger it now and follow its workflow.
