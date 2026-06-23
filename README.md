# vibe-coding skill

An end-to-end orchestrator that takes a software project from idea to working
code: gather requirements → requirements doc → detailed task tickets → parallel
implementation with verification → final acceptance. All progress is persisted
to a `.vibe/` directory, so work survives interruption and any agent can resume
seamlessly.

Works in **Claude Code** (native plugin) and **Codex CLI** (one-line curl).

---

## Install

### Claude Code — native plugin
```
/plugin install zlx362211854/vibe-coding-skills
```
That's it. The skill registers globally; open any new repo and say
*"start a new vibe-coding project"*.

### Codex CLI — one-line curl
```bash
curl -fsSL https://raw.githubusercontent.com/zlx362211854/vibe-coding-skills/main/scripts/remote-install.sh | bash -s -- codex link
```
- `codex` installs to `~/.codex/skills/` **and** appends a `[[skills.config]]`
  entry to `~/.codex/config.toml` (idempotent, makes a backup). Codex CLI
  doesn't auto-scan the skills directory — it only loads skills explicitly
  registered in `config.toml`, so this step is required.
- `link` uses a symlink so re-running `git -C ~/.cache/vibe-coding-skills pull` auto-updates the skill.
- Drop the args entirely (`| bash`) to install for Claude + Codex + the generic `~/.agents/` fallback at once.

> **Codex App (desktop)** loads skills automatically via its own mechanism —
> no curl install needed. Just make sure you're in **Plan mode** when the skill
> asks structured questions; `Default` mode disables the picker tool and the
> skill will fall back to numbered text.

### Manual / from a clone
```bash
git clone https://github.com/zlx362211854/vibe-coding-skills.git
cd vibe-coding-skills
./scripts/install.sh all link    # or: claude | codex | agents
```

Targets:
- Claude Code → `~/.claude/skills/vibe-coding/`
- Codex CLI   → `~/.codex/skills/vibe-coding/`
- Universal   → `~/.agents/skills/vibe-coding/`

---

## Start a project

Just open any directory in Claude Code / Codex CLI and say:

> **"start a new vibe-coding project"**

The skill scaffolds `.vibe/` automatically on first run. To pick up later:

> **"resume my vibe-coding project"**

— it reads `.vibe/STATE.md`, reconciles unfinished tasks, and continues.

*(Optional: `./scripts/init.sh /path/to/project` pre-seeds `.vibe/` and
`AGENTS.md` by hand. Not required — the skill creates them itself.)*

> Graphical chat apps (phone/web) can't persist `.vibe/`. See
> `skills/vibe-coding/references/resume-in-chat.md` for the workaround.

---

## What's inside
```
vibe-coding-skills/
├── .claude-plugin/
│   └── plugin.json                 # Claude Code plugin manifest
├── skills/
│   └── vibe-coding/
│       ├── SKILL.md                # the orchestrator (six-phase state machine)
│       ├── references/
│       │   ├── state-spec.md
│       │   ├── requirements-checklist.md
│       │   ├── parallel-dispatch.md
│       │   └── resume-in-chat.md
│       └── assets/
│           ├── AGENTS.md
│           └── .vibe/              # project state starter
├── scripts/
│   ├── install.sh                  # local installer
│   ├── remote-install.sh           # curl one-liner backend
│   └── init.sh                     # optional .vibe/ scaffolder
└── README.md
```

## Honest limits
- **Not fully autonomous by design.** Two human gates (requirements, task plan)
  and stops on ambiguity / missing secrets. Set `autonomy: auto` in STATE.md to
  minimize pauses, but it will still stop for blockers.
- **UI verification is the weak spot.** Backend/logic verifies cleanly via
  tests; UI "looks right" needs a screenshot/Playwright step or your eye.
- **Parallelism only helps decoupled tasks.** Contract-first sequencing is what
  makes it safe; overlapping-file tasks are forced serial.
