# Architecture Decision Record — Shelter from the Storm

This file logs every consequential architectural decision in this project,
in chronological order. Format inspired by Michael Nygard's ADR style.

Each entry: **what** was decided, **why**, **what we considered and rejected**,
and **when** it was decided.

---

## ADR-001 — Smart Hybrid: configuration-first, Flow-second, Apex last resort
**Date:** 2026-05-14 (Day 1)
**Status:** Accepted

### Decision
Target build allocation:
- 80% Salesforce configuration (objects, fields, layouts, permissions,
  validation rules, record types)
- 15% Flow Builder (screen flows, record-triggered, scheduled)
- 5% Apex / LWC, used only when Flow genuinely cannot do the job

### Why
- The admin executing this build (Daniel) is non-developer
- Apex and LWC create long-term maintenance debt that outlives the original
  developer
- Salesforce native config is upgrade-safe; custom code requires test
  coverage and regression testing on every platform release
- Nonprofit budget cannot sustain ongoing developer engagement

### What we considered and rejected
- **Code-heavy approach** (custom LWC for everything, Apex services).
  Rejected: short-term flexibility, long-term cliff when the developer leaves
- **Pure declarative** (no Apex, no LWC ever). Rejected: a small number of
  features (e.g., complex autonumber formats, true bulk operations) genuinely
  need code; refusing it would produce worse outcomes than using it sparingly

---

## ADR-002 — Production alias renamed to `sfts-prod-DANGER`
**Date:** 2026-05-14 (Day 1)
**Status:** Accepted

### Decision
The production org is registered with the Salesforce CLI under the alias
`sfts-prod-DANGER` rather than the originally-planned `sfts-prod`.

### Why
- The CLI does not distinguish between aliases visually
- A misplaced `--target-org sfts-prod` on a destructive command would cause
  irreversible damage to real client data
- The "DANGER" suffix forces a moment of conscious attention before any
  production-targeted command
- Sandbox (`sfts-dev`) remains the default target throughout the build

### What we considered and rejected
- **`sfts-prod-RO`** — softer signal but less visceral
- **Plain `sfts-prod`** — what the original brief proposed; relies entirely
  on procedure, no built-in visual safety

---

## ADR-003 — API version 66.0 locked in `sfdx-project.json`
**Date:** 2026-05-14 (Day 1)
**Status:** Accepted

### Decision
The project's `sourceApiVersion` is fixed to 66.0, matching what the org is
running. Will be revisited at each Salesforce platform release.

### Why
- Mismatched API versions between project and org cause silent metadata
  drift and confusing deploy errors
- Locking the version makes the project reproducible across machines

---

## Future entries

Decisions made in subsequent days append here. Do not retroactively edit
prior entries — append a new ADR that supersedes if needed.
