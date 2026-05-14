# Day 7 Wrap — 2026-05-14

**Disposition:** Massive day. The website→Salesforce integration went LIVE in production, and we built out the rest of the operational data model (3 new survivor-side objects) plus the entire fundraising data model from scratch (4 new objects + new app). 20+ commits, all deployed to both `sfts-dev` and `sfts-prod-DANGER`.

## Headline outcome

**sftsinc.com is now wired live to production Salesforce.** Real survivor submissions on the quick-intake or 5-step intake form create real records in PROD within ~1 second. The "last 5%" from yesterday's snapshot is now 0%.

Plus: the org now has two coherent Lightning Apps (Operations, Fundraising) covering all major SFTS workflows.

## What shipped (22 commits)

### Morning — Integration debug + production cutover

1. **Integration RESOLVED** — switched from External Client App (which silently failed `app_not_found` despite looking correctly configured) to a classic Connected App deployed via metadata. Documented the root cause in `docs/10-integration-setup-progress.md`.
2. **Integration LIVE in production** — full `force-app/` deploy to `sfts-prod-DANGER` (313 components, 43 seconds, atomic), prod Connected App configured, Netlify env vars swapped, smoke tested with HC-00000 and HC-00001 (deleted after verify).
3. **Pre-deploy cleanup** — moved Log_Service_Delivery quick action to top-level `quickActions/` folder (SFDX requires this for standard-object actions), added `installedPackages/` to `.forceignore` (managed packages already in prod with matching versions).
4. **Post-deploy fixes** — fixed `SFTS_Operations` Lightning App not appearing in App Launcher (permset needed `applicationVisibilities`). Granted `SFTS_Build_All_Access` to `admin@sftsinc.com` in prod to give FLS access to custom fields.

### Afternoon — Drive crawl + operational data model

5. **Crawled the SFTS Drive export** (2 GB, 15 folders) — synthesized the operational, fundraising, grants, board, and marketing workflows. Discovered the gaps in the Salesforce data model relative to actual SFTS work.
6. **`SFTS_Operations_Home` FlexiPage** — custom Home page for the Operations app with welcome banner + 4 list view cards (Open Calls Today / Currently In Shelter / Mandatory Reports Awaiting Response / High Risk Danger Assessments). Needs UI activation via Lightning App Builder (you).
7. **`Financial_Counseling__c`** custom object — 8 fields (Contact, Checkpoint, Session Date, Budgeting Understanding, Financial Position, Goals and Plan, Services Recommended, SFTS Impact). Digitizes the 3-checkpoint financial counseling workflow that lived in `Intake for Financial counseling.docx`.
8. **`Self_Sufficiency_Matrix__c`** custom object — 14 fields including 10 standardized life-domain picklists (Housing / Employment / Food / Health Coverage / Mental Health / Substance Use / Safety / Legal / Financial Literacy / Family Support) all sharing the `SFTS_Self_Sufficiency_Scale` global value set (1-In Crisis through 5-Thriving). Per the Indiana DV Self-Sufficiency Matrix 2013 standard.
9. **`Referral__c`** custom object — 8 fields tracking outbound referrals from SFTS to outside agencies (legal, mental health, housing, etc.). Replaces the BOHCC referral form workflow.
10. **`SFTS_Advocate` permset expansion** — granted advocate-level access (CRUD without delete) to the 3 new survivor-side objects.

### Late afternoon — Fundraising data model

11. **`Donation__c`** custom object — 7 fields (Donor lookup, Amount, Date, Type, Designated For, Acknowledgment Sent, Notes) + `Contact.Donor_Type__c` picklist field. Foundation for donor management + 990-N prep.
12. **`Fundraising_Event__c`** custom object — 8 fields including an auto-calculated `Net_Revenue__c` formula field. Replaces the per-event folder structure (Cowboy Ball, Steak 'n Bake 'n, Chili Cookoff, etc.).
13. **`Grant__c`** custom object — 12 fields tracking the full grant lifecycle from researching → submitted → awarded → reporting → closed. Captures Application_Deadline, Reporting_Due_Date (the field that prevents future-grant disqualification when missed), and Amount Requested vs Awarded.
14. **`SFTS_Fundraising` Lightning App** — coherent home for fundraising work. Tabs: Home, Contacts, Donations, Fundraising Events, Grants, Reports, Dashboards. Purple branding (#5B2C6F) to distinguish from Operations (green).
15. **`Sponsorship_Tier__c`** custom object — 5 fields (Event lookup, Tier Level, Tier Cost, Slots Available, Benefits). Replaces the per-year `Sponsorship Levels.xlsx` files in the Drive.

### Evening — Hardening + UX polish

16. **8 validation rules** across the 5 new survivor + fundraising objects: date-not-future enforcement, required-fields-when-status-X (e.g. `Amount_Awarded required when Grant Status is Awarded`), `Outcome required when Referral Status moves to Closed`, etc.
17. **7 sharing rules** — all-internal R/W on the 7 new objects, matching the established pattern on existing objects.
18. **10 list views** across the 6 new objects covering day-one use cases (Upcoming Grant Deadlines, Reporting Due Soon, Awaiting Acknowledgment, Pending Referrals, Intake SSM Assessments, etc.). Quirk learned: list view metadata uses `"0"/"1"` for checkbox filter values, NOT `"true"/"false"`.
19. **`SFTS_Fundraising_Home` FlexiPage** — custom Home page for the Fundraising app with 4 list view cards (Upcoming Grant Deadlines, Reporting Due Soon, Donations Awaiting Acknowledgment, Upcoming Fundraising Events). Needs UI activation.
20. **4 Quick Actions on Contact** — `New Financial Counseling`, `New SSM Assessment`, `Make Referral`, `Log Donation`. Each creates a child record with Contact prefilled via `targetParentField`. Also FIXED the latent `Log_Service_Delivery` quick action that had been excluded from deploys all day via `.forceignore` (it was missing `targetParentField` — once added it deployed cleanly).
21. **7 compact layouts** — one per new custom object, assigned as primary. Surfaces most-scanned fields in record headers, lookup hover cards, and list view highlights panels.
22. **`SFTS_Fundraiser` permset** — fundraiser-role equivalent of `SFTS_Advocate`. CRUD-minus-delete on Donation, Fundraising_Event, Grant, Sponsorship_Tier, and Contact. App visibility for SFTS_Fundraising. For users who need both roles, assign SFTS_Fundraiser AND SFTS_Advocate.

## State of the orgs at end of day

| Org | Components |
|---|---|
| `sfts-dev` (sandbox) | All Day 7 work deployed. Tested integration via 8 form submissions, all records cleaned. |
| `sfts-prod-DANGER` | All Day 7 work deployed. Smoke-tested HC-00000 and HC-00001 (deleted). Lana can use the system Monday morning. |

## What's still YOUR task (UI work)

Three items couldn't be deployed via metadata and need clicks in Salesforce UI:

1. **Activate the custom Home pages** for both SFTS Operations and SFTS Fundraising apps. Setup → Lightning App Builder → SFTS_Operations_Home → Edit → Activation → Assign as App Default → SFTS Operations → Save. Then again for SFTS_Fundraising_Home → SFTS Fundraising.
2. **Add the new Quick Actions to the Contact page layout.** Setup → Object Manager → Contact → Page Layouts → edit the default layout → drag the 4 new actions (New_Financial_Counseling, New_SSM_Assessment, New_Referral, New_Donation) plus the now-fixed Log_Service_Delivery into the Salesforce Mobile and Lightning Experience Actions section.
3. **Push the branch + draft PR** when you set up a GitHub remote. The branch `claude/quirky-nightingale-10cb2b` has 22 commits ahead of `main`, all locally committed; no `origin` is configured yet.

## Follow-ups for future sessions

### Tier 1 (most useful)
- **Reports + dashboards** — UI-build approach (the metadata XML schema for reports requires CustomReportType infrastructure we haven't set up; UI building is the realistic path). Highest impact: VOCA monthly report, Outcomes report (SSM Intake vs Exit comparison per Contact), Grant Pipeline dashboard.
- **Add the 4 Contact quick actions to the page layout** via a custom Lightning Page (so the assignment is deployable instead of UI-only).
- **Volunteer__c custom object** — third org domain (after Survivors and Donors). The Drive Volunteers folder only had one file, so workflow needs more discovery first.
- **Train Lana** — 30 min walkthrough of SFTS Operations app + Quick Actions on Contact (per cutover plan §6).

### Tier 2 (useful but lower-urgency)
- **Roll-up summary fields**: Total Donations per Contact, Total Awarded per Funder.
- **Cross-record uniqueness validation**: 1 Intake checkpoint per Contact per Shelter_Stay (needs roll-up summary first).
- **Flow automation**: Email alert when `Grant.Reporting_Due_Date` is within 14 days; auto-create Task when Donation ≥ $250 and `Acknowledgment_Sent` = false.
- **Sponsorship__c junction object** — Contact × Sponsorship_Tier so we can track which sponsor claimed which tier at which event.

### Tier 3 (hygiene)
- **Rotate v2 Connected App Consumer Secret** in both orgs (was exposed in chat during debug).
- **Enable Salesforce Pronouns field** in Setup → User Interface if structured pronouns capture is wanted (currently captured only in `Website_Submission_Notes__c`).
- **`sfts-site/` not in git** — the Netlify Function changes (Pronouns/AgeCategory/PreferredCommMethod/Risk_Level/dedup) live only on Daniel's machine + Netlify. Run `git init` in that folder.
- **Push branch + draft PR** once a GitHub remote is set up.

## Key lessons learned today (for future-me)

1. **External Client Apps don't reliably register for JWT bearer flow** in Salesforce. Use classic Connected Apps via metadata deploy. The UI for creating classic Connected Apps was retired in 2024, but the platform still supports them via metadata XML.
2. **A custom field can exist in metadata but be invisible to REST API** when the integration user lacks FLS. Symptom: `INVALID_FIELD: No such column 'X'` even though Tooling API shows X exists. Fix: assign the permset that grants FLS.
3. **Permission sets need explicit `applicationVisibilities`** for Lightning Apps to appear in App Launcher. Deploying just the app metadata isn't enough.
4. **Field permissions can't be set on required fields** — Salesforce auto-grants FLS to required fields. Putting them in `fieldPermissions` causes deploy failures.
5. **Required lookup fields can't use `SetNull` on delete**. Use `Restrict` (block delete if children exist) or `Cascade` (delete children with parent; the latter requires a Salesforce support request to enable on standard custom objects).
6. **QuickAction relationship element is `targetParentField`**, not `targetField`. Hit this multiple times.
7. **List view metadata uses `"0"/"1"` for checkbox filters**, not `"true"/"false"`. The error message is helpful when you know what to look for.
8. **FlexiPage list-view component is `flexipage:filterListCard`**, not `force:listViewManager`. The latter compiles but isn't allowed in App Home page regions.
9. **FlexiPage `pageTemplate` was deprecated** in newer Salesforce API versions. Use `<template><name>...</name></template>` block.
10. **Salesforce Description fields have a 255-char limit** on CustomApplication. Trim aggressively or use `<longDescription>` (where supported).

## Full commit list (newest → oldest, 20 commits since pre-session carryover)

```
eadce41  Day 7: SFTS_Fundraiser permset — fundraiser-role equivalent of SFTS_Advocate
403b79e  Day 7 wrap doc
6d0b0af  Day 7: compact layouts for all 7 new custom objects
9997abf  Day 7: 4 quick actions on Contact + fix Log_Service_Delivery
efdea66  Day 7: sharing rules for 7 new custom objects (all-internal R/W)
03956c3  Day 7: Sponsorship_Tier__c + 10 list views + SFTS Fundraising Home page
d18b18a  Day 7: 8 validation rules across the 5 new custom objects
89cea16  Day 7: SFTS Fundraising Lightning App
9ee54db  Day 7: Track B — Grant__c pipeline tracking
1ea961f  Day 7: Track B continues — Fundraising_Event__c with auto-calculated net revenue
80a64af  Day 7: Track B start — Donation__c + Contact.Donor_Type__c
8635290  Day 7: add Referral__c — track outside agency referrals
490b9d7  Day 7: grant advocates access to FC + SSM
483cda1  Day 7: add Self_Sufficiency_Matrix__c — standardized outcomes tracking
1b510e2  Day 7: add Financial_Counseling__c object — digitize SFTS counseling workflow
dd85ca3  Day 7: add SFTS Operations Home FlexiPage with 4 list view cards
25afbf0  Day 7: grant SFTS_Operations app visibility in both permsets
497cc8b  Day 7: integration LIVE in production (sfts-prod-DANGER)
8ae2c63  Day 7: prep force-app for prod deploy
77741b0  Day 7: integration RESOLVED — classic Connected App via metadata
```

Plus the pre-session carryover commit `5bdeaae` (snapshot doc + progress email draft for Lana). And this doc itself shipping in commit `403b79e`, then updated post-session with the final 2 commits via amendment.

## Working tree state

Clean. All 22 Day-7 commits are on branch `claude/quirky-nightingale-10cb2b`. No `origin` remote configured (yet).
