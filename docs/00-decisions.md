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

---

## ADR-004 — Build on legacy `caseman` + `pmdm` stack, not modern Nonprofit Cloud
**Date:** 2026-05-14 (Day 1)
**Status:** Accepted (approved by Daniel, 2026-05-14)

### Decision (proposed)
This build will use the installed legacy stack — `caseman` (Case Management
for Nonprofits) and `pmdm` (Program Management Module) — rather than the
modern Nonprofit Cloud architecture (CareProgram, CareProgramEnrollee,
BenefitAssignment).

### Why
- The legacy stack is **already installed** with all required objects:
  Intake, Assessment, Case Plan, Goal, Action Item, Client Alert, Client
  Note, Program, Program Engagement, Service, Service Delivery
- Modern NPC PSLs are licensed but the standard objects (CareProgram etc.)
  are **not present** in this org and would require setup activation
  and possibly additional managed package installs
- The 2-week timeline cannot absorb 1-2 days of architecture pivot work
- PMM + caseman is a well-documented, widely-adopted stack for nonprofit
  case management — including DV shelters in the SFDO community
- ICJI and VOCA reporting requirements are agnostic to the underlying
  object architecture; what matters is the demographic + service-unit
  data we capture, not where it sits
- A non-developer admin (Daniel) maintaining this org long-term will
  benefit from a stack that has more public Trailhead / Power of Us
  Hub documentation

### What we considered and rejected
- **Pivot to modern Nonprofit Cloud (CareProgram + BenefitAssignment).**
  Rejected for this build. Future migration is possible but not on the
  critical path. Custom objects we build (Hotline_Call__c,
  Bed_Assignment__c, Mandatory_Report__c) will be designed with clean
  schemas that can be migrated to modern NPC later if desired.

### Open follow-up
- After go-live, evaluate whether to enable modern NPC features as a
  phase-2 migration. Not on the 2-week critical path.

---

## ADR-005 — Org timezone changed to America/Indiana/Indianapolis
**Date:** 2026-05-14 (Day 1, scheduled for Day 2 execution)
**Status:** Accepted (approved by Daniel)

### Decision
Org-level timezone will be changed from `America/Los_Angeles` to
`America/Indiana/Indianapolis` (US Eastern, observing Eastern DST as most
of Indiana does).

### Why
- Shelter from the Storm operates in Indiana
- Pacific timezone would corrupt every timestamp: hotline call times,
  bed assignment in/out, VOCA reporting periods, audit history, etc.

### Note
This is an org-level default. Individual users can still override their
own timezone in their personal settings if any user is genuinely in a
different zone.

---

## ADR-006 — Nonprofit Cloud Case Management RUL reassigned to admin user
**Date:** 2026-05-14 (Day 1)
**Status:** Accepted (approved by Daniel) — to be executed during Step 4 or Day 2

### Decision
The single Nonprofit Cloud Case Management Permission Set License will be
unassigned from `clientadvocate@sftsinc.com` and reassigned to
`admin@sftsinc.com` for the duration of the build.

### Why
- `clientadvocate@sftsinc.com` is dormant (no login since 2026-03-10)
- The build admin needs full access to NPC features for design and
  testing of layouts, permission sets, and flows
- When SFTS hires an active advocate who needs the license, it can be
  reassigned at that time

---

## Future entries

Decisions made in subsequent days append here. Do not retroactively edit
prior entries — append a new ADR that supersedes if needed.
