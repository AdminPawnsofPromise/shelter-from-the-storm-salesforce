# RESUME POINT — Start Here in a Fresh Session

**Purpose:** Single entry point for picking up the SFTS Salesforce build in a new chat or session. Read this first; everything else branches from here.

**As of:** End of Day 8 (2026-05-15)

---

## 🟢 DAY 8 ADDENDUM — Read this first

**Day 8 was a major build day on top of Day 7's go-live.** New stuff that's now live in prod:

### Foundation expansions
- **4 new custom objects** for case-management depth: `Case_Note__c` (interaction journal), `Service_Episode__c` (VOCA service tracking), `Case_Plan__c` (case-level plan), `Case_Goal__c` (SMART goals under a plan, master-detail child)
- **2 catalog objects** with seed data: `SFTS_Program__c` (12 internal SFTS programs) + `SFTS_Resource__c` (15 external benefits like SNAP/TANF/Medicaid/etc.) — see `_seed/programs.json` and `_seed/resources.json`
- **10 new economic-stabilization fields on `caseman__Intake__c`** capturing employment / income / benefits / education / insurance / ID / bank / transportation / childcare
- **Rollup fields on Contact:** `Last_Contact_Date__c`, `Days_Since_Last_Contact__c`, `Total_Service_Hours__c`
- **`Caller_Email__c` on Hotline_Call** for the website's "phone or email" intake field
- **`Completeness_Status__c` formula fields** on both `caseman__Intake__c` and `Hotline_Call__c` (advocate-completion flag)
- **Reports/dashboards foundation:** 4 Custom Report Types deployed (`SFTS_Contacts_with_Shelter_Stays`, `SFTS_Contacts_with_SSM_Assessments`, `SFTS_Donations_by_Designation`, `SFTS_Contacts_with_Donations`) + report folders + dashboard folders. No reports built yet — that's next phase.

### Flow / automation layer (THE BIG ONE)
The website→CRM pipeline now has a brain. On every web intake:
- Owner = Lana (set in JS payload — `Intake_New_Submission_Workflow` Flow used to do this but caseman__Intake__c is a managed-package object with private OWD that blocked the Flow transfer; JS-payload-set was the fix)
- Email alert to BOTH `director@sftsinc.com` (Lana) AND `clientadvocate@sftsinc.com` (Brittany) with deep link
- Follow-up Task created, owned by Lana, due today if Risk_Level=High else tomorrow
- **`Intake_Auto_Task_Templates` Flow** evaluates the new economic fields and auto-creates up to 3 follow-up tasks:
  - Has_Government_ID=No → "Help survivor get replacement ID + fee waiver letter" (High priority, due tomorrow)
  - Has_Insurance=No → "Help apply for Indiana Medicaid / HIP 2.0" (Normal, +3 days)
  - Employment_Status=Unemployed — looking → "Refer to WorkOne + file UI with DV exemption" (Normal, +3 days)

Same Owner-set-via-payload pattern for `Hotline_Call__c`. Hotline_Call also has its own After-Save Flow for email alert + callback task.

`Shelter_Stay_Advance_Intake_Stage` Flow: when a new Shelter Stay is linked to an Intake, auto-advances Intake `caseman__Stage__c` from "Not Started" to "In Progress".

### Critical platform gotcha discovered today
**This org does NOT have "Deploy processes and flows as active" enabled in Setup → Process Automation Settings.** Every Flow deployed via metadata lands as DRAFT regardless of `<status>Active</status>` in the XML. After any Flow deploy, must manually activate via Tooling REST PATCH:
```
PATCH /services/data/v62.0/tooling/sobjects/FlowDefinition/<id>
{ "Metadata": { "activeVersionNumber": <N> } }
```
This is documented in `memory/reference_sfts_flow_activation.md`. If a Flow's expected side effects don't fire after deploy, **check Status FIRST** before debugging logic.

### Website changes (sfts-site/, deployed to Netlify by Daniel via drag-drop)
- `get-help.html` Step 4 expanded with 10 new economic-stabilization questions (trauma-informed phrasing, all optional)
- `netlify/functions/salesforce-intake.js`:
  - Sets `OwnerId` to Lana in Contact + Intake + Hotline_Call payloads
  - Caller_Email vs Caller_Phone routing (detects `@` in input)
  - Maps 10 new form fields to caseman__Intake__c with picklist translation tables
  - Risk_Level expanded: high if abuser_nearby OR weapons OR urgency=tonight OR safety_status=immediate_danger
  - 6 "easy win" intake field mappings populated (Number_of_Children, Children_Present, Shelter_Requested, Referral_Source, caseman__Description, Safe_Phone)
- The website URL pattern in Flow emails is `https://shelterfromthestorminc.lightning.force.com/...` (NOT `sftsinc.lightning.force.com` — that subdomain doesn't exist for the org)

### Permission set assignments
Both Lana (`director@sftsinc.com`) AND Brittany (`clientadvocate@sftsinc.com`) now have all 3 SFTS permsets: SFTS_Advocate + SFTS_Build_All_Access + SFTS_Fundraiser. Brittany handles chief-of-staff + admin functions on top of advocate work.

### Caseman__Intake__c sharing rule
Added `All_Internal_Users_RW` sharing rule on `caseman__Intake__c` so advocates can see Intakes they don't own. Required for any future Flow that touches Intake ownership.

### 🚨 KEY OUTSTANDING WORK — docs/19

End of Day 8, Daniel + Claude did a tab-by-tab UI audit and discovered **the build is solid but page layouts hide ~half the fields**. Every Day-7 + Phase-1 custom object record page is missing critical fields from its Details layout because Salesforce auto-generated minimal layouts and we never customized them.

**Most egregious:**
- **Case Note `Body` field is hidden** — advocates can't see the note text without clicking Edit
- **SSM record page hides 8 of 10 domain scores** — outcomes-measurement gold standard is invisible
- **Contact Related tab missing caseman__Intake** — no way to navigate from a survivor to their case
- **Contact page hides ALL SFTS demographics + rollups** (VOCA, Indiana, caseman, Days_Since_Last_Contact, etc.)
- **Tasks have WhatId but no WhoId** — don't surface on Contact's Activity panel

**[docs/19-ui-audit-gap-list.md](19-ui-audit-gap-list.md) is the master gap list** with priorities P0-P3 and estimated effort.

### 🟣 LANA WALKTHROUGH 2026-05-15 ADDENDUM — meeting follow-up

After the overnight push, Daniel walked Lana through the entire system on a ~3.5h call. **All 22 follow-up items are catalogued in [docs/22-lana-walkthrough-2026-05-15-followup.md](22-lana-walkthrough-2026-05-15-followup.md)** — that's the master to-do list now. Critical context for next session:

- **Lana now has Whisper Flow** installed and uses it for typing — workflow docs should reflect this
- **Brittany (clientadvocate@sftsinc.com)** is the next user to onboard — has SFTS_Advocate permset already
- **June 15, 2026 board meeting** — Daniel presents 20-25 min demo + ask for $2,500 quarterly contract
- **5 highest-leverage immediate fixes:** B1 (web form email validation), B2 (name doubling), B3 (caseman $360 refund investigation), B4 (search fix), B10 (text-thread safety template)
- **$360 caseman package** is the financial loose thread — may require migrating off `caseman__Intake__c` to a custom Intake__c (heavy lift) OR confirming it's free under Power of Us
- **Reports/dashboards (P3.1)** still need UI build — deferred per docs/14 brittleness note
- **Custom Intake FlexiPage (P3.3)** — Lana's homework: tell Daniel which fields she scans first

---

### 🟢 OVERNIGHT 2026-05-15 ADDENDUM — gap list substantially complete

**~6 hours of autonomous build through the gap list. Status:**
- ✅ P0 — all 5 items shipped
- ✅ P1 — all 10 items shipped
- ✅ P2 — 6/7 items shipped (P2.5 docs-only, P2.7 data-quality skipped). Includes the P2.3 schema work I originally said needed daytime: 4 new lookups on Case_Note__c (Hotline_Call, Shelter_Stay, FC, SSM), per-object Log_Case_Note quick actions, Before-Save Flow auto-filling Contact, FLS granted via permsets.
- 🟡 P3 — 2/4 items shipped (P3.2 Home page expanded 4→7 cards, P3.4 Auto-task templates expanded 3→8 profiles).
  - **P3.1 (reports/dashboards)** RETRIED with metadata — same "invalid report type" error as before. Confirmed: must be UI-built per docs/14.
  - **P3.3 (custom Intake FlexiPage)** deferred — needs Lana's input on what to surface above-the-fold.

**Full overnight summary in [docs/21-day-8-overnight-push-wrap.md](21-day-8-overnight-push-wrap.md).** Includes the 5-min smoke-test sequence to verify everything is live in prod.

All schema additions tonight: 4 lookup fields on Case_Note__c (Hotline_Call/Shelter_Stay/FC/SSM, all SetNull, all FLS-granted). All Flow changes activated in prod via Tooling REST PATCH per the SFTS Flow activation gotcha.

---

## Below is the original Day-7 resume content (still mostly accurate)

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
C:\Users\tzadi\Documents\CLAUDE\SFTS\SalesForce\.claude\worktrees\SFTS-GO-LIVE\
```

Main repo (not the worktree):

```
C:\Users\tzadi\Documents\CLAUDE\SFTS\SalesForce\
```

GitHub: https://github.com/AdminPawnsofPromise/shelter-from-the-storm-salesforce

Branch: `SFTS-SALESFORCE-GO-LIVE` (renamed from auto-generated `claude/quirky-nightingale-10cb2b`)

Worktree folder: `.claude/worktrees/SFTS-GO-LIVE/` (renamed from auto-generated `.claude/worktrees/quirky-nightingale-10cb2b/`)

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
