# RESUME POINT — Start Here in a Fresh Session

**Purpose:** Single entry point for picking up the SFTS Salesforce build in a new chat or session. Read this first; everything else branches from here.

**As of:** End of Day 7 (2026-05-14)

---

## What you're working on

A Salesforce Nonprofit Cloud build for **Shelter from the Storm, Inc.**, a domestic violence shelter in Central Indiana. Daniel Stephens is the builder/admin. Lana Stephens is the Executive Director and will be the primary advocate user.

The system is **LIVE in production** as of Day 7. Real survivor submissions on sftsinc.com create real records in production Salesforce within ~1 second.

## Org aliases (sf CLI)

```
sfts-dev          - Sandbox. Default target for all new development.
sfts-prod-DANGER  - Production. Deploy only with explicit go-ahead.
```

Both are authenticated. Don't re-auth unless needed.

## Where the code lives

You are currently in a git worktree:

```
C:\Users\tzadi\Documents\CLAUDE\SFTS\SalesForce\.claude\worktrees\quirky-nightingale-10cb2b\
```

Main repo (not the worktree):

```
C:\Users\tzadi\Documents\CLAUDE\SFTS\SalesForce\
```

GitHub: https://github.com/AdminPawnsofPromise/shelter-from-the-storm-salesforce

Branch: `SFTS-SALESFORCE-GO-LIVE` (renamed from `claude/quirky-nightingale-10cb2b`)

**PR #1 is OPEN** on GitHub. 25+ commits ahead of main. Status: Ready to merge. Don't auto-merge; wait for Daniel's call.

Website code (separate, NOT in this repo): `C:\Users\tzadi\Documents\CLAUDE\SFTS\sfts-site\` — contains the Netlify Function `salesforce-intake.js`. Not version-controlled (no git init yet). Today's changes only live on Daniel's machine + Netlify.

## What's live in production

### Survivor side (SFTS Operations app)
- Hotline_Call__c, Shelter_Stay__c, Mandatory_Report__c, Danger_Assessment__c (pre-Day-7)
- caseman__Intake__c (managed package)
- **Financial_Counseling__c** — 3 checkpoints, 8 fields (NEW)
- **Self_Sufficiency_Matrix__c** — 14 fields, 10 standardized domains (NEW)
- **Referral__c** — outside agency referrals, 8 fields (NEW)
- Custom Home page FlexiPage with list view cards
- 5 quick actions on Contact

### Fundraising side (SFTS Fundraising app — NEW today)
- **Donation__c** — 7 fields + Contact.Donor_Type__c picklist
- **Fundraising_Event__c** — 8 fields, auto-calculated Net Revenue formula
- **Grant__c** — 12 fields, full pipeline lifecycle
- **Sponsorship_Tier__c** — 5 fields, child of Fundraising_Event
- Custom Home page FlexiPage

### Cross-cutting
- 16 validation rules
- 11 sharing rules (all-internal R/W)
- 10 list views
- 7 compact layouts
- Permsets: SFTS_Build_All_Access (admin), SFTS_Advocate (frontline), SFTS_Fundraiser (fundraising-only)
- 44 training records loaded in production (clearly marked "TRAINING" — see [docs/13-training-scenarios.md](13-training-scenarios.md))
- Website→Salesforce integration via Netlify Function + JWT bearer auth

## What's NOT done yet (the to-do list)

In priority order:

### Tier 1 — high operational value
1. **Reports + dashboards** — design specced in detail in [docs/14-reports-and-dashboards-blueprint.md](14-reports-and-dashboards-blueprint.md). 21 reports + 4 dashboards specced. Build via Salesforce UI (Report Builder), then retrieve to metadata. **Recommended starting point if Daniel says "what's next."**
2. **Flow automation "multipliers"** — designed in chat, not built:
   - Donor acknowledgment letter auto-generation + email
   - Scheduled grant deadline alerts (Reporting_Due_Date within 14 days)
   - Mandatory Report supervisor notification on insert
   - Danger Assessment auto-tier (count Yes answers across Q01-Q20)
   - Roll-up summary fields (Total Donations LTV per Contact)
3. **Train Lana** — 30 min walkthrough using the loaded training data. Script is in [docs/13-training-scenarios.md](13-training-scenarios.md). Daniel does this; nothing for an AI to do directly unless asked to update the script.

### Tier 2 — capability expansion
4. **Volunteer__c custom object** — third org domain. Drive folder existed but sparse data; needs discovery with Lana first.
5. **Board__c object** — board governance tracking.
6. **Sponsorship__c junction object** — link Contact (sponsor) to Sponsorship_Tier (which tier they claimed at which event).
7. **Bed Management** — physical bed assignments per shelter unit.

### Tier 3 — hygiene
8. **`sfts-site/` not in git** — run `git init` in the website folder, push to a separate GitHub repo. Today's Netlify Function changes (Pronouns/AgeCategory/Risk_Level/dedup logic) only live on Daniel's machine + Netlify.
9. **Rotate v2 Connected App Consumer Secret** in both orgs (was exposed in chat during Day 7 debug).
10. **Enable Salesforce "Gender Identity and Pronouns Fields"** in Setup → User Interface if structured pronouns capture is wanted.
11. **Merge PR #1 to main** when Daniel is ready (currently open + ready).

### Tier 4 — big swings (multi-session)
12. **Document generation** — automated PDFs for donor acknowledgments, exit paperwork, grant reports.
13. **Experience Cloud portal** — survivor self-service portal.
14. **Twilio + Salesforce** — hotline call routing with auto-record-creation.
15. **Einstein / AI risk scoring** on Danger Assessments.
16. **Survivor "track my case" portal**.

## Key technical patterns established (don't re-discover)

1. **External Client Apps don't reliably register for JWT bearer flow.** Use classic Connected Apps via metadata deploy. Documented in [docs/10-integration-setup-progress.md](10-integration-setup-progress.md).
2. **QuickAction relationship element is `targetParentField`**, not `targetField`. Standard objects (Contact) need quick actions at top-level `quickActions/` folder with `Contact.<ActionName>` naming.
3. **FlexiPage list-view component is `flexipage:filterListCard`** with `entityName` + `filterName` properties.
4. **FlexiPage schema:** use `<template><name>...</name></template>` block (not deprecated `<pageTemplate>`).
5. **List view checkbox filters use `"0"/"1"`**, not `"true"/"false"`.
6. **Required fields auto-grant FLS** — don't put them in `fieldPermissions` (deploy fails).
7. **Required lookup fields can't use `SetNull` on delete** — use `Restrict` or `Cascade` (Cascade requires SF support to enable on custom-to-custom).
8. **Permission sets need explicit `<applicationVisibilities>`** for Lightning Apps to appear in App Launcher.
9. **A custom field can exist in metadata but be invisible to REST API** when the integration user lacks FLS. Symptom: `INVALID_FIELD` errors despite Tooling API showing the field. Fix: assign the permset granting FLS.
10. **Report metadata XML is brittle** — UI-build then retrieve is the realistic path. See [docs/14-reports-and-dashboards-blueprint.md](14-reports-and-dashboards-blueprint.md).

## Daniel's preferences (from session history)

- Wants progress and momentum — has been clear about wanting to "keep building"
- Comfortable with autonomous decisions when the cost of being wrong is low
- Wants honest assessment, not flattery — appreciates being told when something won't work
- Cares about commit hygiene + good documentation (deeply technical but values teaching future-him)
- Pragmatic about UI work — fine to delegate UI clicks to himself rather than fight metadata
- Will say "keep building until told to stop" when he wants autonomous execution
- "Do everything" or "ok next" means he wants action, not a check-in question

## Quick orientation commands

```powershell
# See current git state
git log --oneline -5
git status

# Confirm orgs are still authenticated
sf org list

# See last deploys
sf project deploy report --use-most-recent --target-org sfts-dev
sf project deploy report --use-most-recent --target-org sfts-prod-DANGER
```

## Doc index (read these in this order for full context)

1. **[docs/15-resume-point-after-day-7.md](15-resume-point-after-day-7.md)** ← you are here
2. [docs/12-day-7-wrap.md](12-day-7-wrap.md) — full Day-7 commit-by-commit summary + lessons learned
3. [docs/13-training-scenarios.md](13-training-scenarios.md) — staff training walkthrough using the 44 PROD training records
4. [docs/14-reports-and-dashboards-blueprint.md](14-reports-and-dashboards-blueprint.md) — reports + dashboards design spec (most likely next-build target)
5. [docs/10-integration-setup-progress.md](10-integration-setup-progress.md) — website integration history + how it was eventually solved
6. [docs/00-decisions.md](00-decisions.md) — architectural decision record (ADRs)
7. [docs/08-production-cutover-plan.md](08-production-cutover-plan.md) — original cutover plan; mostly historical now since cutover was executed Day 7
8. [docs/09-advocate-quickref.md](09-advocate-quickref.md) — Lana-facing quick reference

For deeper org discovery: [docs/01-org-discovery.md](01-org-discovery.md).

---

**Start the fresh session by reading this doc + the Day 7 wrap + listing recent commits, and you'll have full context.**
