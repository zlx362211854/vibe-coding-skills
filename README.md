# vibe-coding skill

An end-to-end orchestrator that takes a software project from idea to working
code: gather requirements → requirements doc → detailed task tickets → parallel
implementation with verification → final acceptance. All progress is persisted
to a `.vibe/` directory, so work survives interruption and any agent can resume
seamlessly.

## Why one SKILL.md works on both Codex and Claude
`SKILL.md` is now a cross-tool standard. The *same* file is read natively by
Claude Code, Codex CLI, and many other agents — the only difference is which
directory each tool scans. `install.sh` copies (or symlinks) this folder into
all of them.

> Note: this works in the **CLI** tools (Codex CLI, Claude Code). Graphical chat
> apps (phone/web) have no filesystem, so they can't persist `.vibe/`. See
> `references/resume-in-chat.md` for how to operate there.

## Install
```bash
cd vibe-coding
chmod +x scripts/install.sh
./scripts/install.sh all          # claude + codex + universal fallback
# or: ./scripts/install.sh claude
#     ./scripts/install.sh codex
#     ./scripts/install.sh all link   # symlink instead of copy (auto-updates)
```

Targets:
- Claude Code → `~/.claude/skills/vibe-coding/`
- Codex CLI   → `~/.codex/skills/vibe-coding/`
- Universal   → `~/.agents/skills/vibe-coding/`

## Start a project
One command scaffolds the state starter into your project:
```bash
./scripts/init.sh /path/to/project    # or run with no arg to use the cwd
```
(or copy by hand: `cp -R assets/.vibe /path/to/project/.vibe && cp assets/AGENTS.md /path/to/project/AGENTS.md`)

Open the project in Claude Code or Codex CLI and say **"start a new vibe-coding
project"**. To pick up later, say **"resume my vibe-coding project"** — the skill
reads `.vibe/STATE.md`, reconciles unfinished tasks, and continues.

## What's inside
```
vibe-coding/
├── SKILL.md                          # the orchestrator (six-phase state machine)
├── README.md
├── scripts/
│   ├── install.sh                    # cross-tool installer
│   └── init.sh                       # scaffold .vibe + AGENTS.md into a project
├── references/
│   ├── state-spec.md                 # exact .vibe/ file formats
│   ├── requirements-checklist.md     # PHASE 1 question bank
│   ├── parallel-dispatch.md          # PHASE 3 parallelism + sub-agent briefs
│   └── resume-in-chat.md             # graphical-app fallback
└── assets/
    ├── AGENTS.md                     # drop into each new project root
    └── .vibe/                        # project state starter (seed files)
        ├── STATE.md
        └── tasks/{index.json,_TEMPLATE.md}
```

## Honest limits
- **Not fully autonomous by design.** Two human gates (requirements, task plan)
  and stops on ambiguity / missing secrets. Set `autonomy: auto` in STATE.md to
  minimize pauses, but it will still stop for blockers.
- **UI verification is the weak spot.** Backend/logic verifies cleanly via
  tests; UI "looks right" needs a screenshot/Playwright step or your eye.
- **Parallelism only helps decoupled tasks.** Contract-first sequencing is what
  makes it safe; overlapping-file tasks are forced serial.
