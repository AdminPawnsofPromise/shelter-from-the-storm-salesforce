# Reports + Dashboards UI Build Sheet

**Purpose:** The actionable next-step companion to [docs/14-reports-and-dashboards-blueprint.md](14-reports-and-dashboards-blueprint.md). Once you've built each report in sandbox per this sheet, ping Claude and we'll retrieve to metadata + commit + deploy to prod.

**Pre-flight (already done by Claude in this commit):**
- ✅ Custom Report Types deployed: SFTS_Contacts_with_Shelter_Stays, SFTS_Contacts_with_SSM_Assessments, SFTS_Contacts_with_Donations, SFTS_Donations_by_Designation
- ✅ Folders deployed: `SFTS Operations` (reports + dashboards), `SFTS Fundraising` (reports + dashboards)

**Critical:** Build everything in **sfts-dev (sandbox)** first. Do NOT build directly in prod. Once verified, Claude will retrieve and deploy to prod.

---

## How to start each report

1. App Launcher → **Reports**
2. **New Report** button
3. Pick the **report type** (column below tells you which one)
4. Apply **Filters**, **Columns**, and **Group By** per the blueprint (referenced)
5. **Save As** → pick the folder shown below → name the report exactly as shown

---

## Priority A — 6 reports to start (no CRT needed)

These are all standard report types on already-deployed objects. Build these first.

| # | Name | Report Type to pick | Folder | Blueprint ref |
|---|---|---|---|---|
| R1 | `My Open Hotline Callbacks` | Hotline Calls | SFTS Operations | [§R1](14-reports-and-dashboards-blueprint.md#r1-my-open-hotline-callbacks) |
| R2 | `Currently in Shelter — Days Remaining` | Shelter Stays | SFTS Operations | [§R2](14-reports-and-dashboards-blueprint.md#r2-currently-in-shelter--days-remaining) |
| R3 | `Mandatory Reports Awaiting Response` | Mandatory Reports | SFTS Operations | [§R3](14-reports-and-dashboards-blueprint.md#r3-mandatory-reports-awaiting-response) |
| R9 | `Hotline Call Volume by Month` | Hotline Calls | SFTS Operations | [§R9](14-reports-and-dashboards-blueprint.md#r9-hotline-call-volume-by-month) |
| R15 | `Donations YTD with Acknowledgment Status` | Donations | SFTS Fundraising | [§R15](14-reports-and-dashboards-blueprint.md#r15-donations-ytd-with-acknowledgment-status) |
| R19 | `Grants — Reporting Due Soon` | Grants | SFTS Fundraising | [§R19](14-reports-and-dashboards-blueprint.md#r19-grants--reporting-due-soon) |

## Priority B — 5 reports needed to power D1 + D3 dashboards

| # | Name | Report Type to pick | Folder | Blueprint ref |
|---|---|---|---|---|
| R7 | `High-Risk Danger Assessments — Last 90 Days` | Danger Assessments | SFTS Operations | [§R7](14-reports-and-dashboards-blueprint.md#r7-high-risk-danger-assessments--last-90-days) |
| R8 | `Active Shelter Stays Approaching 90 Days` | Shelter Stays | SFTS Operations | [§R8](14-reports-and-dashboards-blueprint.md#r8-active-shelter-stays-approaching-90-days) |
| R16 | `Top Donors by Lifetime Giving` | **SFTS: Contacts with Donations** (CRT) | SFTS Fundraising | [§R16](14-reports-and-dashboards-blueprint.md#r16-top-donors-by-lifetime-giving) |
| R18 | `Grant Pipeline by Status + Funder` | Grants | SFTS Fundraising | [§R18](14-reports-and-dashboards-blueprint.md#r18-grant-pipeline-by-status--funder) |
| R20 | `Event ROI Comparison` | Fundraising Events | SFTS Fundraising | [§R20](14-reports-and-dashboards-blueprint.md#r20-event-roi-comparison) |

## Priority C — 2 dashboards (after Priority A + B reports exist)

| # | Name | Folder | Components | Blueprint ref |
|---|---|---|---|---|
| D1 | `SFTS Operations Daily Snapshot` | SFTS Operations | R1, R2, R3, R8, R9, R7 | [§D1](14-reports-and-dashboards-blueprint.md#d1-sfts-operations-daily-snapshot) |
| D3 | `SFTS Fundraising Overview` | SFTS Fundraising | R15, R16, R18, R19, R20 | [§D3](14-reports-and-dashboards-blueprint.md#d3-sfts-fundraising-overview) |

---

## When a report won't save / quirks to know

- **Can't find the CRT** in the report type picker → it's filed under category "Other Reports" (Salesforce rejected `customobjects` as a category value on this org/API version; the CRTs use `other` instead). Search by name: type "SFTS" in the picker filter.
- **Save fails with "Folder not visible"** → make sure folder access is "Public ReadWrite". Both folders were deployed that way; if Salesforce changed it, fix in Reports → folder → Share.
- **Date filters** — Salesforce literal date ranges (`LAST_N_DAYS:30`, `THIS_YEAR`, `NEXT_N_DAYS:60`) are typed into the filter value field, not selected from a picklist. The blueprint shows the exact strings to use.
- **Matrix report empty grid** → ensure you set both Row Group AND Column Group. A matrix with only rows is just a Summary report.

---

## When you're done

Ping Claude: "reports + dashboards done in sandbox, pull them down."

Claude will then run:
```powershell
sf project retrieve start -m "Report:SFTS_Operations" -m "Report:SFTS_Fundraising" -o sfts-dev
sf project retrieve start -m "Dashboard:SFTS_Operations" -m "Dashboard:SFTS_Fundraising" -o sfts-dev
```

…verify the metadata looks clean, commit, then deploy to `sfts-prod-DANGER`.

---

## What's NOT in this build sheet (deferred)

Reports R4, R5, R6, R10, R11, R12, R13, R14, R17, R21 from the blueprint — saved for a future pass. R14 (SSM Intake vs Exit) and R17 (Lapsed Donors) are the two with build complications that may need Flow / Apex / joined reports. The rest are straightforward and can be added incrementally once you've validated the Priority A/B pattern.
