# Reports + Dashboards Blueprint

**Purpose:** Design spec for every report and dashboard SFTS should build in Salesforce. Use this as the build sheet when you sit down in the Salesforce UI (Reports tab → New Report).

**Why not metadata XML?** Salesforce report metadata is notoriously finicky (we hit "invalid report type" trying earlier). The Report Builder UI is visual + iterative + saves time. Once reports are built in UI, run `sf project retrieve start -m Report:SFTS_Operations/* -o sfts-dev` to capture them into metadata for version control + prod promotion.

**Order of operations:** Build all reports in **sandbox first**, validate they work, then deploy to prod via metadata. Don't build directly in prod — too easy to make mistakes.

---

## Custom Report Types to build first (3)

Standard report types (auto-generated per custom object) cover most cases. But for cross-object reports we need custom report types. Build these in **Setup → Report Types → New Custom Report Type**:

### CRT-1: "Contacts with Shelter Stays"
- **Primary object:** Contact
- **Child relationship:** Shelter_Stay__c (via `Shelter_Stay__c.Contact__c`)
- **Why:** powers the "Survivors with Length of Stay" report + outcomes work
- **Category:** SFTS Operations

### CRT-2: "Contacts with SSM Assessments"
- **Primary object:** Contact
- **Child relationship:** Self_Sufficiency_Matrix__c (via `Self_Sufficiency_Matrix__c.Contact__c`)
- **Why:** powers the Outcomes report (Intake vs Exit SSM scores per Contact)
- **Category:** SFTS Operations

### CRT-3: "Donations by Designation"
- **Primary object:** Donation__c
- **(no child)**
- **Why:** powers funder-restricted vs unrestricted reporting; 990-N prep
- **Category:** SFTS Fundraising

---

## Reports — Advocate-facing (8)

These show up in Lana's daily workflow. Build in sandbox, deploy to prod, save to "SFTS Operations" report folder.

### R1: My Open Hotline Callbacks
- **Object:** Hotline_Call__c (standard report type)
- **Format:** Tabular
- **Filters:**
  - `Outcome__c IS NULL` OR `Outcome__c = 'Safety Plan Created'`
  - `Call_Start_DateTime__c >= LAST_N_DAYS:30`
  - `Phone_Safe_To_Return__c = TRUE` (only callable)
- **Columns:** Name, Caller_Name__c, Caller_Phone__c, Call_Type__c, Primary_Issue__c, Call_Start_DateTime__c, Outcome_Notes__c
- **Sort:** Call_Start_DateTime__c DESC
- **Audience:** Lana (daily — first thing she opens)
- **Why:** "What calls do I need to follow up on?" — replaces the manual call-log spreadsheet

### R2: Currently in Shelter — Days Remaining
- **Object:** Shelter_Stay__c
- **Format:** Tabular
- **Filters:**
  - `Status__c = Active`
  - `Check_Out_DateTime__c IS NULL`
- **Columns:** Name, Contact__c, Check_In_DateTime__c, Number_of_Adults__c, Number_of_Children__c, Pets__c, Length_of_Stay_Days__c (existing formula)
- **Sort:** Check_In_DateTime__c ASC (longest-staying first)
- **Audience:** Lana, shelter coordinator
- **Why:** weekly check-in per House Rules + 3-month contract tracking

### R3: Mandatory Reports Awaiting Response
- **Object:** Mandatory_Report__c
- **Format:** Tabular
- **Filters:** `Outcome_Status__c = 'Awaiting Response'`
- **Columns:** Name, About_Contact__c, Report_Type__c, Method__c, Report_DateTime__c, Reporter__c
- **Sort:** Report_DateTime__c ASC (oldest first — these need follow-up)
- **Audience:** Lana, Director
- **Why:** statutory follow-up — agencies need to confirm receipt + outcome

### R4: Recent Self-Sufficiency Assessments
- **Object:** Self_Sufficiency_Matrix__c
- **Format:** Tabular
- **Filters:** `Assessment_Date__c = LAST_N_DAYS:90`
- **Columns:** Name, Contact__c, Checkpoint__c, Assessment_Date__c, Housing__c, Employment_Income__c, Safety__c, Mental_Health__c
- **Sort:** Assessment_Date__c DESC
- **Audience:** Lana
- **Why:** see who's been assessed lately + spot survivors due for re-assessment

### R5: Pending Referrals — All Active
- **Object:** Referral__c
- **Format:** Summary (group by Status__c)
- **Filters:** `Status__c IN (Pending, Initiated, Engaged)`
- **Columns:** Name, Contact__c, Referred_To_Agency__c, Referral_Type__c, Referral_Date__c
- **Group by:** Status__c, then Referral_Type__c
- **Sort:** Referral_Date__c ASC (oldest pending first)
- **Audience:** Lana
- **Why:** referrals get lost easily — this is the catch-up view

### R6: Financial Counseling — Checkpoints Completed per Contact
- **Object:** Financial_Counseling__c
- **Format:** Matrix
- **Rows:** Contact__c
- **Columns:** Checkpoint__c
- **Show:** Record Count
- **Why:** see who's had Beginning but not Middle/End — surfaces missed check-ins

### R7: High-Risk Danger Assessments — Last 90 Days
- **Object:** Danger_Assessment__c
- **Format:** Tabular
- **Filters:** `Assessment_DateTime__c = LAST_N_DAYS:90` AND `Total_Score__c >= 14` (or whatever threshold maps to High/Extreme tier — check formula)
- **Columns:** Name, Contact__c, Assessment_DateTime__c, Total_Score__c, Danger_Tier__c
- **Sort:** Total_Score__c DESC
- **Audience:** Lana, Director
- **Why:** safety prioritization — who needs heightened attention

### R8: Active Shelter Stays Approaching 90 Days
- **Object:** Shelter_Stay__c
- **Format:** Tabular
- **Filters:**
  - `Status__c = Active`
  - `Length_of_Stay_Days__c >= 75`
- **Columns:** Name, Contact__c, Check_In_DateTime__c, Length_of_Stay_Days__c, Number_of_Adults__c, Number_of_Children__c
- **Sort:** Length_of_Stay_Days__c DESC
- **Audience:** Lana, Daniel
- **Why:** per House Rules, residential contract is 3 months. This surfaces who needs the renewal-vs-exit conversation.

---

## Reports — Operational + Admin (6)

Saved to "SFTS Operations" folder; Daniel's weekly/monthly reviews.

### R9: Hotline Call Volume by Month
- **Object:** Hotline_Call__c
- **Format:** Summary
- **Group by:** Call_Start_DateTime__c (group by Calendar Month)
- **Show:** Record Count, also count of `Mandatory_Report_Triggered__c = TRUE`, count of `Imminent_Danger_Indicated__c = TRUE`
- **Filters:** `Call_Start_DateTime__c = THIS_FISCAL_YEAR`
- **Chart:** Vertical bar
- **Audience:** Daniel, board
- **Why:** "How much hotline activity did we have?" — trend tracking

### R10: Hotline Calls by Primary Issue + Outcome
- **Object:** Hotline_Call__c
- **Format:** Matrix
- **Rows:** Primary_Issue__c
- **Columns:** Outcome__c
- **Show:** Record Count
- **Filters:** `Call_Start_DateTime__c = THIS_FISCAL_YEAR`
- **Chart:** Stacked bar
- **Audience:** Daniel, funders
- **Why:** what kind of calls + how they resolved — VOCA reporting

### R11: Shelter Admissions vs Exits per Month
- **Object:** Shelter_Stay__c
- **Format:** Summary
- **Group by:** Check_In_DateTime__c (calendar month)
- **Show:** Record Count grouped, plus count of `Status__c = Exited`
- **Filters:** Calendar year
- **Audience:** Daniel, board
- **Why:** occupancy flow — capacity planning

### R12: Mandatory Report Compliance Tracking
- **Object:** Mandatory_Report__c
- **Format:** Summary
- **Group by:** Report_Type__c (APS / DCS / Law Enforcement / Other)
- **Show:** Record Count, also count grouped by Outcome_Status__c
- **Audience:** Daniel, director
- **Why:** compliance audit trail — show timely filing

### R13: Service Delivery by Program
- **Object:** `pmdm__ServiceDelivery__c` (managed package — already installed)
- **Format:** Summary
- **Group by:** `pmdm__Service__c.pmdm__Program__c.Name`
- **Show:** Record Count, Sum of `pmdm__Quantity__c`
- **Filters:** `pmdm__DeliveryDate__c = LAST_N_MONTHS:3`
- **Audience:** Daniel, funders (esp. VOCA)
- **Why:** what services were delivered + how much — federal grant reporting requirement

### R14: SSM Outcomes — Intake vs Exit Comparison
- **Custom Report Type:** CRT-2 (Contacts with SSM Assessments)
- **Format:** Tabular
- **Show:** Each Contact that has both an Intake AND an Exit SSM assessment, with the score deltas across domains
- **Build trick:** Use joined report OR build with row-level formulas. May be easier as a custom Lightning component if reports can't express it natively. Fallback: build a Tabular report of "All SSM Assessments" and let users sort + group manually.
- **Audience:** Funders (THE outcomes report)
- **Why:** the quantitative evidence that SFTS works — biggest funder report

---

## Reports — Fundraising (5)

Saved to a new **"SFTS Fundraising"** report folder. Daniel + future fundraiser.

### R15: Donations YTD with Acknowledgment Status
- **Object:** Donation__c
- **Format:** Summary
- **Group by:** Donation_Type__c, then Designated_For__c
- **Show:** Sum of Amount__c, Record Count, also count of `Acknowledgment_Sent__c = FALSE`
- **Filters:** `Donation_Date__c = THIS_YEAR`
- **Chart:** Donut by Designated_For__c
- **Audience:** Daniel, board treasurer
- **Why:** "How much have we raised + where?" + IRS compliance check on acks

### R16: Top Donors by Lifetime Giving
- **Custom Report Type:** Contacts with Donations
- **Format:** Summary
- **Group by:** Contact (Donor name)
- **Show:** Sum of Amount__c (lifetime total per donor), Record Count
- **Sort:** Sum of Amount DESC, limit top 50
- **Audience:** Daniel, board, fundraising chair
- **Why:** prioritize donor stewardship; identify major donors

### R17: Lapsed Donors (gave last year, not this year)
- **Custom Report Type:** Contacts with Donations
- **Format:** Tabular
- **Filters:** Contact has at least one Donation in `LAST_YEAR` but NO donations in `THIS_YEAR`
  - **Build note:** This is hard in standard reports — may need a joined report or two side-by-side reports the user compares manually. Or use SOQL via a Lightning component.
- **Columns:** Contact Name, Last Donation Date, Last Donation Amount, Email, Phone
- **Audience:** Fundraising team
- **Why:** lapsed donors are 5x more likely to give back than new prospects — re-engagement priority

### R18: Grant Pipeline by Status + Funder
- **Object:** Grant__c
- **Format:** Matrix
- **Rows:** Funder__c
- **Columns:** Status__c
- **Show:** Sum of Amount_Requested__c (or Amount_Awarded__c for closed)
- **Audience:** Daniel
- **Why:** funder pipeline at a glance — where's the money

### R19: Grants — Reporting Due Soon
- **Object:** Grant__c
- **Format:** Tabular
- **Filters:** `Reporting_Due_Date__c = NEXT_N_DAYS:60` AND `Status__c IN (In Progress, Reporting Due)`
- **Columns:** Name, Funder__c, Reporting_Due_Date__c, Amount_Awarded__c
- **Sort:** Reporting_Due_Date__c ASC
- **Audience:** Daniel
- **Why:** miss a reporting deadline = disqualified from future grants. This is the failsafe.

---

## Reports — Events (2)

### R20: Event ROI Comparison
- **Object:** Fundraising_Event__c
- **Format:** Tabular
- **Filters:** `Status__c = 'Closed Out'`
- **Columns:** Name, Event_Date__c, Event_Type__c, Attendance__c, Gross_Revenue__c, Expenses__c, Net_Revenue__c
- **Sort:** Net_Revenue__c DESC
- **Audience:** Daniel, event chair
- **Why:** which events return the most — capacity planning

### R21: Sponsorship Slots Open per Event
- **Object:** Sponsorship_Tier__c
- **Format:** Summary
- **Group by:** Fundraising_Event__c, then Tier_Level__c
- **Show:** Sum of Tier_Cost__c, Sum of Slots_Available__c
- **Filters:** Linked event status is Active or Planning
- **Audience:** Event chair, fundraising team
- **Why:** "We have 2 Gold slots and 1 Title slot left to sell" — sales pipeline view

---

## Dashboards (4)

### D1: SFTS Operations Daily Snapshot
- **Folder:** SFTS Operations
- **Running user:** Daniel (admin perspective so all records visible)
- **Components:**
  1. **R1 (My Open Hotline Callbacks)** — list view component, top-left
  2. **R2 (Currently in Shelter)** — list view component, top-right
  3. **R3 (Mandatory Reports Awaiting Response)** — list, middle-left
  4. **R8 (Approaching 90 Days)** — list, middle-right
  5. **R9 (Hotline Volume by Month)** — bar chart, bottom-left
  6. **R7 (High-Risk Danger Assessments)** — table, bottom-right
- **Why:** Lana's morning view — answers "what needs my attention today?"

### D2: SFTS Outcomes (Funder-Facing)
- **Folder:** SFTS Operations → subfolder "Funder Reports"
- **Components:**
  1. **R14 (SSM Outcomes Intake vs Exit)** — table
  2. **R11 (Shelter Admissions vs Exits)** — line chart
  3. **R10 (Hotline Calls by Issue/Outcome)** — stacked bar
  4. **R13 (Service Delivery by Program)** — donut
- **Why:** export this dashboard to PDF + send to VOCA/BRCF/etc. each reporting cycle

### D3: SFTS Fundraising Overview
- **Folder:** SFTS Fundraising
- **Components:**
  1. **R15 (Donations YTD with Ack Status)** — donut
  2. **R16 (Top Donors by LTV)** — bar
  3. **R18 (Grant Pipeline by Funder + Status)** — matrix table
  4. **R19 (Grants — Reporting Due Soon)** — table
  5. **R20 (Event ROI)** — bar
- **Why:** Daniel's fundraising morning view

### D4: SFTS Board Executive Summary
- **Folder:** SFTS Operations → "Board Reports"
- **Components:** Aggregates from above, simplified — just headline numbers
  1. Survivors served YTD (single number from Contact count)
  2. Hotline calls YTD (single number)
  3. Funds raised YTD (single number from R15)
  4. Active shelter occupants today (single number from R2)
  5. Outcomes mini-chart (R14 simplified)
- **Why:** monthly board meeting — board members want headline numbers, not detail

---

## How to build each report in Salesforce UI

Generic playbook (one-time learning curve, ~5 min per report after that):

1. **App Launcher → Reports** (find it in the SFTS Operations app)
2. **New Report**
3. **Select report type** from the catalog:
   - For standard reports: search for the object name (e.g., "Hotline Calls")
   - For custom report types we built: search "SFTS"
4. **Set filters** in the Filters panel (left side)
5. **Add columns** by dragging fields from the panel into the columns area
6. **Group by** (for summary/matrix) — drag a field into the Group Rows area
7. **Add chart** (for summary) — click "Add Chart" top right, choose type
8. **Run report** → confirm it shows expected data
9. **Save As** → pick "SFTS Operations" folder → name per this blueprint

For **dashboards**:
1. **App Launcher → Dashboards** → New Dashboard
2. **Add Component** → select a saved report → choose visualization (chart type or table)
3. Drag components into a grid layout
4. **Save** → "SFTS Operations" folder

---

## Order to build (priority sequence)

If you only had 2 hours total, build in this order:

1. **R1 (Open Callbacks)** — most-used by Lana
2. **R2 (Currently in Shelter)** — daily occupancy check
3. **R3 (Mandatory Reports Awaiting Response)** — compliance + safety
4. **R9 (Hotline Volume by Month)** — board-meeting fodder
5. **R15 (Donations YTD)** — fundraising headline
6. **R19 (Grants Reporting Due Soon)** — prevents disqualification
7. **D1 (Daily Snapshot dashboard)** — wraps R1-3 into one view
8. **D3 (Fundraising Overview dashboard)** — wraps R15-19

The other 13 reports can be added incrementally as needs surface.

---

## After building — capture to metadata

When reports + dashboards are live in **sandbox** (sfts-dev), retrieve them to this repo:

```powershell
# Reports
sf project retrieve start -m Report:SFTS_Operations/* -o sfts-dev
# Dashboards
sf project retrieve start -m Dashboard:SFTS_Operations/* -o sfts-dev
# Custom report types
sf project retrieve start -m ReportType -o sfts-dev
```

Then commit + deploy to prod via the standard `sf project deploy start` pattern we've used all day.

---

## Follow-ups for future sessions

- Build the reports per the priority sequence above
- Run scheduled subscriptions (Reports → schedule daily/weekly email) for D1 (Lana morning) and D3 (Daniel morning)
- Build the lapsed-donors logic (R17) — may require an Apex class or Flow if joined reports don't suffice
- Consider Tableau CRM (Analytics Studio) for advanced outcomes visualization once SSM data accumulates
