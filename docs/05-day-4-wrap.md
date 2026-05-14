# Day 4 Wrap — 2026-05-15

## What got built

### Lightning App: "SFTS Operations"
- Custom app with branded header color (`#2C3E36`, matches the website logo)
- Navigation menu includes: Home, Hotline Call, Contact, Shelter Stay, Danger Assessment, Mandatory Report, Case, Program, Service Delivery, Reports, Dashboards
- Now lives in App Launcher as "SFTS Operations" — the single entry point for daily work

### 8 custom list views (operational defaults)
| Object | List View | What it shows |
|---|---|---|
| Hotline_Call | Today's Calls | Calls started today (open or closed) |
| Hotline_Call | High-Risk Calls | Imminent danger flagged |
| Shelter_Stay | Currently In Shelter | Active stays with no Check_Out_DateTime |
| Shelter_Stay | Exited This Month | Stays with Check_Out in current month |
| Danger_Assessment | High-Risk Assessments | Total Score >= 14 (Severe / Extreme tiers) |
| Danger_Assessment | Assessments This Month | Assessments in current month |
| Mandatory_Report | Awaiting Response | Outcome Status = Awaiting Response |
| Mandatory_Report | All Reports This Year | Reports filed this calendar year |

### Foundational records seeded (PMM stack)
- **5 Programs** in `pmdm__Program__c`: 24/7 Hotline, Emergency Shelter, Court Advocacy, Childrens Program, Outreach and Non-Residential
- **20 Services** in `pmdm__Service__c`, distributed across the 5 programs:
  - Hotline: Hotline Crisis Call, Information and Referral (phone), Safety Planning (phone)
  - Shelter: Bed Night, Case Management Session, Group Counseling, Individual Counseling, Safety Planning Session, Material Assistance
  - Court: Court Accompaniment, Protective Order Assistance, Legal Information and Referral, Victim Impact Statement Help
  - Children: Childrens Group Session, Child Individual Session, Childcare Provided
  - Outreach: Community Education Presentation, Outreach Counseling, Medical Hospital Accompaniment, Information and Referral (outreach)

These records are **the foundation for VOCA service-delivery reporting.** Every `pmdm__ServiceDelivery__c` record (logged service to a Contact) references one of these Services, which roll up to a Program.

### Re-runnable test data seeding script
`scripts/seed-test-data.ps1` — creates a deterministic set of synthetic data clearly tagged `SYNTHETIC`:
- 5 Contacts (mix of counties, ACP statuses, languages)
- 18 Hotline Calls (varied dates, outcomes, danger flags, anonymous + identified)
- 4 Shelter Stays (2 currently active, 2 exited)
- 3 Danger Assessments (one each of Severe / Increased / Variable tier)
- 1 Mandatory Report (DCS, Investigation Opened)

Re-run any time you want fresh test data — the script cleans prior SYNTHETIC records first.

### Reports + Dashboard — built in UI, not as metadata

**Honest call I made:** Salesforce's metadata XML format for `Report` is designed for *copying reports between orgs*, not for *creating them from scratch*. It expects the report-type to already exist, and report-types need their own metadata that's even more verbose. The total XML for 5 reports + 5 report types + 1 dashboard would have been ~600 lines, error-prone, and would still produce reports identical to what Salesforce's Report Builder UI can generate in 30 seconds.

So: I deployed the **`SFTS_Operations` report folder** (where the reports live), then stopped. Daniel builds the actual reports in the UI — much faster, much friendlier, and the data model is already prepped to support every report we need.

#### How to build the 5 starter reports in the UI (~10 minutes total)

1. App Launcher → **Reports** → New Report
2. Choose report type → search for the object you want (e.g., "Hotline Calls")
3. Use the visual builder to:
   - **Hotline Volume by Outcome** — Report type: Hotline Calls. Group by Outcome. Add bar chart.
   - **Imminent Danger Calls** — Report type: Hotline Calls. Filter: Imminent Danger Indicated = True. Tabular.
   - **Currently In Shelter** — Report type: Shelter Stays. Filter: Status = Active. Add columns: Contact, Check-In, Length of Stay, Adults, Children.
   - **Danger Assessment Tier Distribution** — Report type: Danger Assessments. Group by Danger Tier. Add pie chart.
   - **Mandatory Reports by Type** — Report type: Mandatory Reports. Group by Report Type. Tabular.
4. Save each to the **SFTS Operations** folder.

#### How to build the dashboard (~5 minutes)
1. Dashboards tab → New Dashboard → "SFTS Operations Dashboard"
2. Add 4 components, each backed by one of the reports above:
   - Top-left: Currently In Shelter (count component)
   - Top-right: High-Risk Calls (Imminent Danger) (count)
   - Bottom-left: DA Tier Distribution (donut chart)
   - Bottom-right: Hotline Volume by Outcome (bar chart)
3. Save to SFTS Operations folder.

This 15 minutes of Daniel work + UI clicking is faster than the equivalent metadata XML.

## Git state at end of Day 4

(Will be ~21 commits when this commit lands.) Working tree clean once committed.

## Day 5 plan (proposed)

This is where the big payoff happens: **the website → Salesforce integration** captured in ADR-012.

1. **Build Daniel's reports + dashboard in the UI** (15 min start-of-day exercise)
2. **Connected App + JWT bearer auth flow** for server-to-server authentication
3. **Netlify Function** that receives form submissions from sftsinc.com and POSTs to Salesforce REST API:
   - `quick-intake` form → `Hotline_Call__c` record
   - `intake` form → `caseman__Intake__c` + Contact creation
4. **Auth keypair generation and Netlify env var configuration**
5. **End-to-end test** — Daniel submits a test form on his website, sees the record appear in Salesforce within seconds

## What you should do before Day 5

1. **Sanity-check today's work in the sandbox UI:**
   - App Launcher → "SFTS Operations" app should appear
   - Click any custom object's tab; the new list views should be in the dropdown
   - Hotline Calls tab → "Today's Calls" and "High-Risk Calls" list views should be selectable
   - Contacts list view → you should see the 5 SYN_ test contacts
2. **Build the 5 reports** in the SFTS Operations folder (UI walkthrough above; takes ~10 minutes)
3. **Build the dashboard** (UI walkthrough above; ~5 minutes)
4. Then come back and we tackle the Netlify integration.

If reports/dashboard feels intimidating, no problem — we walk through it together when you're back. Just tell me "let's do reports" and I'll narrate the clicks.
