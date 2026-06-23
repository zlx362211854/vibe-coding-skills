# Requirements Checklist (PHASE 1)

Ask in small groups. Don't dump all of this at once. Stop when you have enough
to write the three docs with no major unknowns. Record answers as you go.

## How to ask (read every time)

- **Always enumerate options.** Every closed-set question must be presented as
  numbered choices + "Other (specify)". No bare open prompts when a finite set
  exists. Example BAD: "what framework do you want?" Example GOOD:
  ```
  Pick the front-end framework:
    1. React + Vite
    2. Next.js (SSR)
    3. Vue 3 + Vite
    4. SvelteKit
    5. Other (specify)
  ```
- **Use the host's structured-picker tool. This is mandatory when available.**
  - Claude Code → `AskUserQuestion` (multi-select + auto Other).
  - Codex CLI   → `request_user_input` (1–3 questions per call, each with 2–3
    options, first option suffixed `(Recommended)`; client auto-appends Other —
    do not add it yourself).
  - Other CLIs without a picker → numbered text fallback ("reply with the
    number"), same enumerated discipline.
  Plain-text questions are a LAST RESORT, not the default.
- **Never assume.** If the user said "app" without saying which kind, you do
  NOT know if it's web / iOS / Android / 小程序 / desktop. Ask first.

## 0. Platform / form-factor  (ALWAYS ASK FIRST)

What kind of "app" are we building? Required pick — do NOT skip, do NOT default
to web. Present these (adapt the list to context, but always enumerate):

  1. Web app (browser)
  2. Native iOS (Swift / SwiftUI)
  3. Native Android (Kotlin)
  4. Cross-platform mobile (React Native / Flutter / Expo)
  5. WeChat / Alipay mini-program (小程序)
  6. Desktop app (Electron / Tauri / native)
  7. CLI / terminal tool
  8. Browser extension
  9. Backend / API service only (no UI)
  10. Other (specify)

All downstream architecture and tech-selection questions MUST be filtered by
this answer (e.g. don't ask about Vercel for a native iOS app; don't ask about
TailwindCSS for a CLI).

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
