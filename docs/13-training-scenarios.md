# Training Scenarios — SFTS Operations + Fundraising

**Purpose:** Guided walkthrough for training new SFTS staff (Lana, future advocates, future fundraisers) on the live Salesforce system. Uses 44 pre-loaded training records in PROD — every record has "TRAINING" in the name or notes so it's safe to demo and easy to delete later.

**Time:** ~30 min for advocate training (survivor side). +15 min for fundraising side if needed.

**Setup:** Trainee logs into Salesforce production with their own credentials. App Launcher → SFTS Operations.

---

## The 5 training survivors

Each survivor's profile is designed to demonstrate specific workflows. Visit them in order — each builds on the last.

### 1. Alice Trainee — Crisis Caller (no shelter yet)

**Find her:** SFTS Operations → Contacts tab → list view "All Contacts" → "TRAINING Alice Trainee"

**Story:** Alice called the hotline this morning. She's in immediate distress but isn't ready to come into shelter. Lana needs to schedule a callback and create a safety plan with her.

**Demonstrates:**
- The Home page "Open Calls Today" card surfaces her call
- Drill into a Hotline_Call__c record to see all caller-level fields
- `Outcome` field workflow (Safety Plan Created)
- `Phone_Safe_To_Return__c` checkbox (yes for Alice — safe to call back)
- Caller is also a Contact record (linked via `Contact__c` lookup)

**Key training point:** Not every hotline call becomes an intake. Some survivors just need information, safety planning, or someone to listen. Alice's record models that path.

---

### 2. Brenda Practice — Recently Admitted (3 weeks in shelter)

**Find her:** Contacts → "TRAINING Brenda Practice" → scroll down to Related lists

**Story:** Brenda called 3 weeks ago, came in same day, has been in shelter ever since. Single adult, no children. Adjusting to the program.

**Demonstrates:**
- A Contact with multiple related records: 1 Hotline Call → 1 Intake → 1 Shelter Stay → 1 Danger Assessment → 1 SSM Intake assessment → 1 Financial Counseling Beginning session
- The Related list pattern (scroll down on a Contact record to see all linked records)
- Shelter_Stay status = "Active", check-in 3 weeks ago, no check-out
- Danger Assessment with moderate scoring (only a couple of high-risk indicators)
- Self_Sufficiency_Matrix at "Intake" checkpoint — baseline scores

**Key training point:** Every active resident should have an Intake + Shelter Stay + at minimum one Danger Assessment + one SSM Intake. Brenda models a clean, recent admission.

**Practice task:** Have Lana add a new Financial Counseling "Beginning" session for Brenda via the "New Financial Counseling Session" Quick Action on her Contact page. (Note: after Day 7, the Quick Action needs to be added to the page layout first — see admin setup note.)

---

### 3. Cynthia Demo — Mid-Program (day 42, 2 kids)

**Find her:** Contacts → "TRAINING Cynthia Demo"

**Story:** Cynthia called 6 weeks ago in crisis — high danger indicators (gun in home, recent strangulation, escalating violence). Admitted same evening. Now mid-program with her 2 children (ages 4 and 7). Legal proceedings in flight; first job secured; working hard.

**Demonstrates:**
- High-risk Danger Assessment (many Yes answers on Q01, Q02, Q06, Q10, Q14, Q18, Q19)
- SSM progression: Intake (mostly In Crisis) → Mid-Program (Stable across most domains)
- Financial Counseling progression: Beginning (no budgeting, no bank account) → Middle (bank account opened, first paycheck, working on credit)
- 2 Referrals: one Initiated (Legal Aid for protection order + custody) + one Closed - Success (WorkOne employment placement)
- Children in shelter — `Number_of_Children__c=2` on Shelter Stay

**Key training point:** Cynthia is the model of "active casework." Multiple services touched, progression visible, but still in program. Most of Lana's daily work will look like this.

**Practice task:** Have Lana add a new Referral via the "Make Referral" Quick Action — perhaps to a mental health provider. Use Status=Pending, Type=Mental Health, fill in Reason.

---

### 4. Diana Walkthrough — Exited Successfully (last week)

**Find her:** Contacts → "TRAINING Diana Walkthrough"

**Story:** Diana called 3 months ago — severe crisis across multiple domains, single mother with 1 child + a dog. Completed the full residential program. Exited 1 week ago to her own permanent housing in Marion County. The success story SFTS reports to funders.

**Demonstrates:**
- A complete program arc, start to finish
- SSM full progression: Intake (mostly 1-In Crisis) → Mid-Program (mix of Stable/Vulnerable) → Exit (mostly 4-Building Capacity) — *this is the outcomes story SFTS sells to funders*
- Financial Counseling all 3 checkpoints: Beginning, Middle, End
- 3 Referrals — all Closed - Success (Legal aid for divorce, Housing voucher, Alumni mentor for aftercare)
- Shelter Stay with `Status = Exited`, `Check_Out_DateTime` populated, `Exit_Reason = Goals Met`, `Exit_Destination = Own Apartment or House`
- Final Danger Assessment showing low scores (safety improved during program)

**Key training point:** Diana is the **outcomes story**. When SFTS reports to VOCA/BRCF/funders, comparing Diana's Intake SSM scores to her Exit SSM scores is the quantitative outcomes evidence. Show Lana how to find this comparison via a Contact record's Related lists.

**Practice task:** Walk Lana through how to **read** Diana's progression: open Contact → scroll to Self_Sufficiency_Matrix related list → click Intake assessment, click Mid-Program, click Exit. Show the score improvement across domains.

---

### 5. Erica Example — Mandatory Report Case

**Find her:** Contacts → "TRAINING Erica Example"

**Story:** Erica called the hotline this morning. There's a child in the home, allegations of abuse against a household member, and Erica is in imminent danger. Per Indiana law, this triggered a mandatory report to DCS, filed within the call.

**Demonstrates:**
- Hotline Call with `Imminent_Danger_Indicated__c = true` and `Mandatory_Report_Triggered__c = true`
- The "Open Calls Today" Home page card flags this call prominently
- The linked Mandatory_Report__c record: Report_Type=DCS, Method=Phone, Outcome_Status=Awaiting Response
- The full chain: 1 Hotline Call → 1 Mandatory Report, both linked to Contact (via `About_Contact__c` on Mandatory Report)

**Key training point:** Not every call results in a mandatory report. But when one does, the workflow is non-negotiable per statute. Show Lana the **"Mandatory Reports Awaiting Response"** list view on the Home page — this is what gets watched for follow-up from the agency.

---

## Fundraising-side training (skip if not relevant to the trainee)

If you're training someone for fundraising work (not Lana — likely a future hire or board volunteer):

### Donations + Donors

**Find them:** SFTS Fundraising app (App Launcher → SFTS Fundraising) → Contacts tab → filter for `Donor_Type__c IS NOT NULL`

- **TRAINING DonorOne Smith** — Individual donor, gave $500 last month (check), Acknowledged ✅
- **TRAINING DonorTwo Acme Corp** — Business donor, gave $2,500 today (ACH), **Acknowledgment NOT yet sent** — this is in the "Awaiting Acknowledgment" list view on the SFTS Fundraising Home page

**Practice task:** Find DonorTwo via the "Awaiting Acknowledgment" Home page card → open the Donation → mark Acknowledgment_Sent = true after the letter goes out.

### Events

**Find it:** SFTS Fundraising → Fundraising Events → **TRAINING Cowboy Ball 2026**

- Status = Active/Promoting
- Event_Date = ~3 months from now
- Already has $2,500 in expenses (save-the-dates etc.) but $0 in gross revenue yet
- Has 1 Sponsorship Tier (Gold, $5,000, 3 slots) attached via Related list

**Practice task:** Walk through the lifecycle: Status changes Planning → Active → Held → Closed Out. Show Net_Revenue formula updates as gross/expenses change.

### Grants

**Find it:** SFTS Fundraising → Grants → **TRAINING BRCF 2026 Operating**

- Status = In Progress (awarded $20K, less than $25K request)
- Application_Deadline + Submitted_Date = last month
- Decision_Date = today
- **Reporting_Due_Date = ~9 months from now** — surfaces in the "Reporting Due Soon" Home page card

**Practice task:** Show how the Home page "Upcoming Deadlines" + "Reporting Due Soon" cards make grant management non-magical. Talk through what happens when Reporting_Due_Date passes (you owe BRCF a report or risk future grants).

---

## After training — cleanup

Once training is done and Lana has been working with the system for a few days, delete the TRAINING records so they don't clutter real list views:

```powershell
# In dependency order: children first, then parents
foreach ($obj in @('Referral__c','Financial_Counseling__c','Self_Sufficiency_Matrix__c','Danger_Assessment__c','Mandatory_Report__c','Shelter_Stay__c','caseman__Intake__c','Hotline_Call__c','Sponsorship_Tier__c','Grant__c','Fundraising_Event__c','Donation__c')) {
    $ids = (sf data query -q "SELECT Id FROM $obj WHERE CreatedDate = LAST_N_DAYS:14 AND CreatedById = '005am00000DPMM1AAP'" -o sfts-prod-DANGER --json | ConvertFrom-Json).result.records.Id
    foreach ($id in $ids) { sf data delete record --sobject $obj --record-id $id -o sfts-prod-DANGER --no-prompt }
}
$contactIds = (sf data query -q "SELECT Id FROM Contact WHERE FirstName LIKE 'TRAINING %'" -o sfts-prod-DANGER --json | ConvertFrom-Json).result.records.Id
foreach ($id in $contactIds) { sf data delete record --sobject Contact --record-id $id -o sfts-prod-DANGER --no-prompt }
```

**Don't delete until training is fully complete** — Lana may want to return to these records to remember workflows. Recommend keeping them at least 2 weeks after first training, longer if she's still learning.

---

## Admin pre-training checklist

Before sitting down with Lana, the admin needs to have done:

- [ ] **Activate the SFTS Operations Home page** (Setup → Lightning App Builder → SFTS_Operations_Home → Activation → App Default → SFTS Operations → Save)
- [ ] **Activate the SFTS Fundraising Home page** (same dance, for SFTS_Fundraising_Home → SFTS Fundraising)
- [ ] **Add the 5 Contact Quick Actions to the Contact page layout** (Setup → Object Manager → Contact → Page Layouts → drag New_Financial_Counseling, New_SSM_Assessment, New_Referral, New_Donation, Log_Service_Delivery into the Salesforce Mobile and Lightning Experience Actions section)
- [ ] **Assign `SFTS_Advocate` permset to Lana** (`sf org assign permset --name SFTS_Advocate --target-org sfts-prod-DANGER --on-behalf-of director@sftsinc.com` — or via Setup UI)
- [ ] **Verify Lana can log in to PROD** and the SFTS Operations app appears in her App Launcher
- [ ] **Print this doc** or have it open on a second screen during the session
