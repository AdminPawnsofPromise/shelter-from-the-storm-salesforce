# Website-to-CRM Integration Plan

**Purpose:** End-to-end architecture for the SFTS survivor pipeline. Web intake → Salesforce → advocate workflow → outcomes. Covers Programs catalog, external Resources catalog (SNAP / TANF / etc.), expanded Intake questions, intake-driven task templates ("profiles"), and the website-form changes that feed it.

**Status:** Planning artifact. Phase 1 (Programs + Resources catalog) shipping tonight; Phase 2 (intake-form expansion + task templates) next session.

---

## Vision

Today: survivor fills out web form → record lands in Salesforce → advocate sees Risk_Level and a notes blob → advocate manually figures out what to do next.

After this plan: survivor fills out web form → record lands in Salesforce → **system already knows** which programs the survivor needs, which benefits they should apply for, what the first 5 tasks are for the advocate, and what the rehabilitation arc looks like. Advocate's first action is *executing* the plan, not *building* it.

---

## The 4 layers

### Layer 1: Programs catalog (what SFTS offers)

A `SFTS_Program__c` object lists every internal service SFTS provides. ~12 generic DV-shelter programs to seed:

| Program | Category |
|---|---|
| Emergency Shelter | Housing |
| Transitional Housing | Housing |
| Crisis Hotline | Crisis Response |
| Court Advocacy | Legal |
| Legal Advocacy | Legal |
| Children's Support Group | Youth |
| Survivor Support Group | Group |
| Trauma-Informed Counseling | Mental Health |
| Financial Literacy Class | Economic |
| Self-Sufficiency Coaching | Economic |
| Safety Planning | Crisis Response |
| Community Outreach & Education | Prevention |

Service_Episode__c gets a `Program__c` lookup so every service touchpoint ties to a program → enables grant reporting and program-level outcomes ("how many survivors did Court Advocacy serve last quarter").

### Layer 2: Resources catalog (what survivors apply for externally)

A `SFTS_Resource__c` object lists external benefits + services SFTS helps survivors access. Seed ~15 records grouped by category:

**Food / Basic Needs:**
- SNAP (Supplemental Nutrition Assistance Program)
- WIC (Women, Infants, and Children)
- TANF (Temporary Assistance for Needy Families)
- Local food pantries

**Housing:**
- Section 8 Housing Choice Voucher
- Indiana Emergency Rental Assistance
- LIHEAP (Low-Income Home Energy Assistance)

**Income / Employment:**
- Indiana Unemployment Insurance
- SSDI / SSI
- WorkOne / Indiana Career Connect

**Healthcare:**
- Indiana Medicaid / HIP 2.0
- Marketplace (ACA) Insurance
- Crime Victim Compensation Fund

**Legal / Safety:**
- Indiana Legal Services (free legal aid)
- VINE (Victim Information & Notification)
- Indiana ACP (Address Confidentiality — survivor already has fields for this)

Each resource has: Name, Category, Eligibility_Notes, Apply_URL, Apply_Phone, SFTS_Internal_Notes ("how we help survivors apply"), Active flag.

Referral__c gets a `Resource__c` lookup so an advocate logging "we helped Brenda apply for SNAP" links to the canonical SNAP record. Then Daniel can run "all Resource applications, grouped by Resource, count of pending" — knowing instantly which benefits we're best at and which need workflow tightening.

### Layer 3: Expanded Intake questions (the rehab picture)

Today's intake captures safety, household, current support needs. **Missing: the economic + stabilization picture** that drives what programs/resources to recommend.

New fields on `caseman__Intake__c`:

| Field | Type | Purpose |
|---|---|---|
| `Employment_Status__c` | Picklist (Full-time, Part-time, Self-employed, Unemployed — looking, Unemployed — not looking, Disabled, Student, Retired, Other) | Drives employment-related referrals |
| `Income_Source__c` | Multi-select picklist (Job, Self-employment, SSI/SSDI, TANF, Unemployment, Family support, None, Other) | Drives benefits gap analysis |
| `Approximate_Monthly_Income__c` | Number | Eligibility check for needs-based benefits |
| `Currently_Receiving_Benefits__c` | Multi-select (SNAP, TANF, WIC, Section 8, Medicaid, Unemployment, SSI/SSDI, None, Unknown) | Don't reapply for what they already have |
| `Has_Insurance__c` | Picklist (Yes — private, Yes — Medicaid, Yes — Other, No, Don't know) | Healthcare planning |
| `Education_Level__c` | Picklist (Less than HS, HS/GED, Some college, Associate's, Bachelor's, Graduate, Trade/Cert, Other) | Job placement planning |
| `Has_Bank_Account__c` | Checkbox | Direct deposit eligibility for benefits |
| `Has_Government_ID__c` | Checkbox | Most benefits require ID; if no, that's task #1 |
| `Vehicle_Available__c` | Checkbox | Transportation planning |
| `Childcare_Status__c` | Picklist (Have reliable, Need help, Not applicable) | Drives Children's Support Group enrollment + childcare referrals |

These are all optional on the form. The completeness flag pattern flags missing ones; advocates fill in during callback.

### Layer 4: Intake-driven task templates ("profiles")

This is the smart layer. On Intake creation, a **Record-Triggered Flow** evaluates the new fields + existing safety/urgency signals, and **auto-creates Tasks + Case_Goals** based on which "profile" the survivor matches.

**Example profiles:**

#### Profile A: "Crisis, in shelter, needs full rebuild"
**Triggers when:** `urgency = tonight` OR `safety_status = immediate_danger` AND `Employment_Status = Unemployed` AND no benefits currently receiving

**Auto-creates Tasks:**
1. Today: Confirm safe location, log Hotline_Call if not already
2. Today+1: Initial Danger Assessment
3. Today+1: Begin shelter intake paperwork (House Rules orientation)
4. Today+3: Apply for SNAP (file Resource Application)
5. Today+3: Apply for TANF (file Resource Application)
6. Today+7: Schedule first Trauma-Informed Counseling session
7. Today+7: Indiana Medicaid eligibility check

**Auto-creates Case_Goals** (in a new Case_Plan):
- Domain=Safety: "Maintain safe living situation through 90-day shelter contract"
- Domain=Income: "Secure income stream — benefits OR employment — within 60 days"
- Domain=Housing: "Identify transitional or independent housing by exit date"

#### Profile B: "Recently left, employed, just needs safety planning"
**Triggers when:** `safety_status = recently_left` AND `Employment_Status = Full-time`

**Auto-creates Tasks:**
1. Today+1: Safety planning session (set up appointment)
2. Today+3: PO consultation if `urgent_need[] includes protective_order`
3. Today+7: Optional Survivor Support Group invitation
4. Today+14: Follow-up wellness check

#### Profile C: "Information seeker, not in crisis"
**Triggers when:** `urgency = not_urgent` AND `urgent_need[] includes info_only`

**Auto-creates Tasks:**
1. Today+1: Send resource packet
2. Today+7: Optional follow-up — anything change?

(More profiles can be added as patterns emerge from real intake data.)

The implementation: one big Record-Triggered Flow with decision branches that read the intake answers and create the relevant task set. Tasks reference Resource__c records (for benefit applications) and Program__c records (for service enrollment).

---

## Website form changes (Phase 2)

The intake form (`get-help.html` Step 4 — "What kind of support are you looking for?") gets a new section: **"A few practical questions to help us prepare your plan."**

Adds fields matching the new Intake schema above. All optional, trauma-informed language:

- "Are you working right now?" (radio)
- "Roughly what's coming in each month?" (text — free-form to avoid hard categorization)
- "Are you already getting any of these?" (checkbox grid for SNAP, TANF, WIC, etc.)
- "Do you have health insurance right now?" (radio)
- "Highest schooling you finished?" (select)
- "Do you have a bank account?" (yes/no, optional)
- "Do you have a government-issued ID handy?" (yes/no, optional)
- "How do you usually get around?" (radio)

Each field appears in `salesforce-intake.js` and maps to the new caseman__Intake__c fields.

---

## End-to-end pipeline (after this plan ships)

```
SURVIVOR fills out get-help.html
   ↓ Netlify Forms event
NETLIFY FUNCTION salesforce-intake.js
   ↓ JWT auth + REST API
SALESFORCE
   ↓ Insert caseman__Intake__c (Contact created/matched)
RECORD-TRIGGERED FLOW (existing): Intake_New_Submission_Workflow
   ↓ Assigns Owner, sends email, creates initial follow-up Task
RECORD-TRIGGERED FLOW (new): Intake_Task_Template_Generator
   ↓ Reads new economic fields + existing safety fields
   ↓ Matches a Profile (A / B / C / ...)
   ↓ Creates:
     - 4-8 Tasks with appropriate due dates and assignees
     - 1 Case_Plan with 3-5 Case_Goals
     - 2-5 Resource_Applications (status = Researching) for benefits
     - Program_Enrollment placeholders if Profile maps to specific programs
   ↓ Sends "your case plan is ready" email to advocate

ADVOCATE opens the Intake record:
   - Sees auto-generated Case Plan with goals
   - Sees Tasks queued in their My_Tasks view
   - Sees Resource Applications in Researching status (ready to start)
   - Modifies/removes anything that doesn't fit before contacting survivor
   - First callback is informed, prepared, fast
```

The advocate goes from "what do I do with this submission?" to "here's the plan, let me refine it" in 30 seconds.

---

## Phases

### Phase 1 — Foundation (TONIGHT)
- SFTS_Program__c object + 12 seed records
- SFTS_Resource__c object + 15 seed records
- Service_Episode__c.Program__c lookup
- Referral__c.Resource__c lookup
- Permsets + tabs + app updates
- Permset assignments confirmed

**Outcome:** advocates can manually associate programs/resources to records but no automation yet.

### Phase 2 — Intake expansion + task templates (NEXT SESSION)
- ~10 new fields on caseman__Intake__c (employment, income, benefits, education, etc.)
- Website get-help.html updated: new Step 4 questions
- salesforce-intake.js updated: map new fields
- Intake_Task_Template_Generator Flow with 3 starter profiles (A/B/C above)
- Roll-up: Total_Open_Resource_Applications on Contact

**Outcome:** new intakes auto-generate a starter plan; advocate refines instead of starts from scratch.

### Phase 3 — Outcomes + reporting (LATER)
- Roll-ups: Total_Benefits_Approved per Contact, Total_Programs_Enrolled, etc.
- Reports: "Resource Application Pipeline" (similar to Grant Pipeline)
- Dashboard: "Survivor Stabilization Snapshot" — for board reporting

### Phase 4 — Loop optimization (LATER)
- ML-style profile learning: as more intakes happen, refine which task sets actually correlate with positive outcomes
- More profiles, finer-grained matching

---

## What this does NOT touch (intentionally)

- We're **not** replacing the existing intake/Hotline_Call structure — we're adding layers on top
- We're **not** replacing caseman or pmdm — we're staying SFTS-native and selectively integrating
- We're **not** changing the website's trauma-informed tone — new fields are all optional, gentle phrasing
- Survivor privacy is preserved: nothing in Programs or Resources reveals survivor identity outside Salesforce

---

## Open design questions for next session

1. **Should Program_Enrollment be its own object or implicit via Service_Episode.Program__c?** Phase 1 implements implicit (via lookup). Phase 3 might warrant explicit enrollment tracking.
2. **Should Resource_Application be its own object or extend Referral__c?** Phase 1 implements via Referral.Resource__c lookup. If application lifecycle gets richer (multi-step status, renewal cycles), spin out separately.
3. **How aggressive should the auto-task generation be?** Daniel + Lana should pilot Phase 2 with sandbox training data before going live in prod. The risk of bad profiles is creating tasks the advocate has to dismiss — annoying.
4. **Brittany's role in the workflow:** since she has chief-of-staff + advocate access, should some auto-tasks default to her vs. Lana? Could add a "Task_Type assignment" config (admin tasks → Brittany, advocacy tasks → Lana).
