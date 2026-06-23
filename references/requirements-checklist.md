# Requirements Checklist (PHASE 1)

Ask in small groups. Don't dump all of this at once. Stop when you have enough
to write the three docs with no major unknowns. Record answers as you go.

## A. Business / Product
- Who is the target user? What problem does this solve for them?
- The 1–3 core scenarios the MVP MUST support.
- Explicit non-goals (what we are deliberately NOT building in v1).
- Any hard constraints: deadline, budget, must-use platform.
- What does "done enough to ship" look like? (acceptance in plain words)

## B. Architecture
- Single app or front-end + back-end split? Any mobile?
- Deploy target: Vercel / Netlify / own server / serverless / desktop / none yet.
- Does it need: a database? auth/login? file storage? realtime? background jobs?
  payments? email? third-party APIs?
- Expected scale (rough): toy/demo vs real users. Affects choices, not over-eng.

## C. Tech selection (record the WHY for each)
- Language(s).
- Front-end framework + UI library + styling approach + state management.
- Back-end framework / runtime (or "none / BaaS").
- Database + ORM/driver.
- Key third-party services and which need API keys/secrets.
- If the user has no preference, propose a sensible default stack and let them
  veto. Don't stall on bikeshedding.

## D. Code style / conventions
- Naming conventions, directory layout preference.
- Formatter + linter (e.g. Prettier + ESLint) and whether to enforce in verify.
- Testing expectation: none / smoke only / unit on logic / e2e on key flows.
- TypeScript strictness, commit message style, anything else they care about.

## Output of this phase
- `.vibe/requirements.md` — A + acceptance items.
- `.vibe/architecture.md` — B + C with rationale.
- `.vibe/conventions.md` — D.

Then summarize and HOLD at the gate for user approval.
