# Workflow Docs Inventory — Handoff to Manus

**Purpose:** Catalog every SFTS Salesforce workflow that needs a "this is how you actually do this end-to-end" doc, with the planned flow for each (even where the UI is still rough). Manus to expand each entry into a full how-to.

**As of:** 2026-05-15 end of Day 8 + P0 layout fixes shipped.

**Audience for the final docs:** Lana Stephens (Executive Director / primary advocate, first-time Salesforce user) and Brittany (Chief of Staff / second advocate, also new to Salesforce).

---

## Doc status legend

- ✅ **Done** — covered well in an existing doc
- 🟡 **Partial** — touched in an existing doc but missing depth, decision trees, or the why
- 🔴 **Missing** — no how-to exists; the system supports it but no one has been told how to use it

Existing docs Manus should read first:
- `docs/09-advocate-quickref.md` — one-page intro, covers hotline + shelter + danger assessment basics
- `docs/13-training-scenarios.md` — 5 training survivor walkthroughs (Alice/Brenda/Cynthia/Dana/Erika)
- `docs/12-day-7-wrap.md` — go-live wrap, full system summary
- `docs/14-reports-and-dashboards-blueprint.md` — what each report measures
- `docs/15-resume-point-after-day-7.md` — current state-of-the-build
- `docs/19-ui-audit-gap-list.md` — what's polished vs raw in the UI

---

## A. Intake workflows (how a survivor first enters the system)

### A1. Website intake → advocate follow-up 🟡
**Plan:** Survivor fills `/get-help` form on sftsinc.com. Netlify Function creates Contact + caseman__Intake__c (+ optional Hotline_Call_c if they preferred phone) in prod within ~1 second. Owner = Lana. Email alert fires to both director@ and clientadvocate@ with a deep link. A follow-up Task is auto-created (due today if Risk_Level=High, else tomorrow). Up to 3 economic-stabilization auto-tasks may also be created based on form answers (no ID / no insurance / unemployed-looking). **Advocate's job:** open the email link → read the Intake → check Activity panel on the Contact for all auto-tasks → call/email survivor within the SLA → log a Case Note → mark the auto-tasks complete as you act on them.
**Current state:** Pipeline LIVE since Day 7. Email + tasks fire correctly. **UI gap:** Intake record page is the caseman package's default FlexiPage — hides our 10 new economic-stabilization fields. Document the "scroll down to Related → caseman fields" workaround until we build a custom FlexiPage in Phase 3.

### A2. Phone hotline intake (live caller) ✅
**Plan:** Caller hits the 24/7 line → advocate clicks **`+` icon top-right → "Log Hotline Call"** → guided 2-screen form → save creates Hotline_Call__c. Triage critical fields *while on the phone:* Phone_Safe_To_Return, Imminent_Danger_Indicated, Caller_County (auto-flags In_Service_Area for Marion/Shelby/Johnson/Hancock), Primary_Issue. Outcome + Outcome_Notes are required. If shelter needed, advocate then creates the Contact + caseman__Intake__c manually from the Hotline_Call.
**Current state:** Covered in advocate quickref. Manus: copy-paste field-by-field and expand with phone-script examples.

### A3. Email-only hotline contact 🔴
**Plan:** Some survivors can't safely make a phone call but can email. The website form now accepts either phone OR email. When `caller_input` contains `@`, the Netlify Function writes to Caller_Email instead of Caller_Phone. **Advocate's job:** check the "Awaiting Callback" list view, see records with Caller_Email set, reply from clientadvocate@ rather than calling, document the email thread in Outcome_Notes (do NOT paste the whole email — link to Gmail thread URL instead). If response gets no answer in 48 hours, mark Outcome = "No Response" and close.
**Current state:** Pipeline LIVE. No doc explains the email vs phone branching to advocates.

### A4. Walk-in intake 🔴
**Plan:** Survivor shows up at the door (rare but happens). Advocate creates Contact first → then caseman__Intake__c from the Contact's "+ New" related list → set Origin = "Walk-in" (need to add this picklist option if not present), Lead_Source = "Walk-in" on Contact. Skip the Hotline_Call layer. If admitting to shelter same day, follow A5 → shelter stay flow next.
**Current state:** Possible in system but undocumented. Lana may not know to skip the Hotline_Call.

---

## B. Assessment workflows (clinical / outcomes tracking)

### B1. Danger Assessment (Campbell DA-20) 🟡
**Plan:** Administer with consent, ideally on Day 1 of contact and again at 90-day checkpoint and discharge. **When NOT to do it:** survivor still with abuser unless private setting confirmed (it can trigger trauma reactions and reveal she's planning to leave). **How:** Contact record → New → Danger Assessment OR via the "New SSM Assessment" quick action area (TBD whether DA gets its own quick action; for now use related list). 20 questions, each Yes/No/Unknown/Declined to Answer. Total_Score auto-calculates. **Tier interpretation:** Variable (0-7) / Increased (8-13) / Severe (14-17) / Extreme (18+). **What to do at each tier:** Variable = standard safety planning, document in Case Note. Increased = enhanced safety planning + offer Danger Assessment Follow-up in 30 days. Severe = trigger Mandatory_Report consideration if minor children involved, recommend emergency shelter, daily check-ins. Extreme = ALL of the above + supervisor notification + consider law enforcement coordination if survivor consents. **Field-by-field translation:** each Campbell question maps to gender-neutral wording in our object; original Campbell text in field tooltips for clinician validation.
**Current state:** Object + scoring works. Advocate quickref has 4-tier summary. Missing: the "when to do it / when NOT to do it" guidance, full tier action protocols, the consent script.

### B2. Self-Sufficiency Matrix (SSM-10) 🔴
**Plan:** Administer at four checkpoints: **Intake** (within first 7 days), **3-Month**, **6-Month**, **Discharge**. Each is a separate Self_Sufficiency_Matrix__c record with `Checkpoint__c` set. Survivor + advocate score together across 10 domains: Safety, Housing, Employment_Income, Food, Health_Coverage, Mental_Health, Substance_Use, Legal, Financial_Literacy, Family_Support. Each domain scored 1-5: **1 = In Crisis** (immediate threat / no resources), **2 = Vulnerable** (insufficient resources, frequent crisis), **3 = Stable** (basic needs met but precarious), **4 = Safe** (consistent resources, building toward thriving), **5 = Thriving** (full self-sufficiency in this domain). Notes field captures qualitative context. **The point:** track progress over time — report B3 ("SSM Progress by Survivor") shows the lift across checkpoints, which is what VOCA/foundation grants want to see. **Advocate's job at each checkpoint:** schedule a 60-min sit-down → walk through each domain → score with the survivor's input (not for her) → write 1-2 sentence note per domain → save. The new layout (P0.2, shipped 2026-05-15) shows all 10 domains in a 2-column grid.
**Current state:** Object + layout polished after P0.2. Zero documentation on cadence, scoring rubric, or interview technique. **This is the highest-value missing doc** because SSM data is the outcomes-measurement spine of every grant report.

### B3. Financial Counseling sessions 🔴
**Plan:** Three-checkpoint structure: **Beginning** (within first 30 days — establish financial baseline), **Middle** (~90-day mark — track behavior change), **Discharge** (final — measure outcomes). Each is a Financial_Counseling__c record with `Checkpoint__c` set. Fields: Budgeting_Understanding (1-5 scale), Financial_Position (long text — savings, debts, income), Goals_and_Plan (what survivor committed to), Services_Recommended (what advocate suggested), SFTS_Impact (what changed because of our help). **Advocate's job at each session:** 45-min one-on-one → review previous session's Goals_and_Plan if any → update Financial_Position → set Services_Recommended → confirm next session date. Pair with Referral records when sending survivor to outside agency (e.g., Brightpoint for utility assistance).
**Current state:** Object exists. Layout missing 4 of 8 fields (P1.4 fix pending). No doc explains the 3-checkpoint cadence or what each field is for. Lana may not know the session structure is intentional.

---

## C. Daily-operations workflows (what advocates do every shift)

### C1. Case Note logging 🟡
**Plan:** Log every meaningful interaction with a survivor: phone call, in-person conversation, court accompaniment, advocacy email sent on her behalf, etc. **Where:** Contact record → "Log Case Note" quick action (now sortOrder 0 after P0.4 fix) OR Intake record → Related → Case Notes → New. **Note_Type values:** Phone_Call / In_Person / Email / Court / Other. **Subject** = one-line summary ("Called to confirm Friday's hearing"). **Body** = the actual note (markdown OK). **Duration_Minutes** = billable time. **Confidential** = check if therapist-client privilege applies — these don't show in standard reports. **Intake** lookup = link to the active intake if she has one (lets the note also surface on the Intake's Related tab). The new layout (P0.1, shipped 2026-05-15) finally shows the Body on the record page; previously you had to click Edit to read your own note.
**Current state:** Object + flow live. P0.1 fixed the visibility bug. No doc explains the Confidential flag, when to populate Intake__c, or what good case-note hygiene looks like.

### C2. Service Episode logging (VOCA reporting fuel) 🟡
**Plan:** After every billable advocate-survivor interaction, log a Service_Episode__c. **Required for VOCA + FVPSA grant reporting** — if it's not logged, it didn't happen as far as the grant is concerned. Fields: Service_Type (Crisis_Counseling / Court_Accompaniment / Shelter_Bed_Night / Information_Referral / etc), Service_Subtype (drills into specifics), Hours_Spent (decimal hours — 0.5 = 30 min), VOCA_Eligible (check if survivor consented to VOCA documentation), Funding_Source (VOCA / FVPSA / Foundation_X / Private), Program (lookup to SFTS_Program__c if applicable). **Daily rhythm:** at end of shift, advocate scans the day's calendar/notes → creates one Service_Episode per billable interaction → confirms hours sum approximately to her shift. **Why:** quarterly VOCA reports need clean hours-by-service-type breakdowns. Garbage in, garbage out.
**Current state:** Object live. Advocate quickref mentions it briefly. Missing: a sample "what does a clean day of Service Episodes look like" walkthrough, the eligibility rules for VOCA vs FVPSA, when to leave VOCA_Eligible unchecked.

### C3. Auto-task management 🔴
**Plan:** When a new web intake lands, the system creates up to 4 tasks owned by Lana: (1) "Follow up on new intake — call within 24h" (always), (2) "Help survivor get replacement government ID" (if Has_Government_ID = No), (3) "Help survivor apply for Indiana Medicaid / HIP 2.0" (if Has_Insurance = No), (4) "Refer survivor to WorkOne + file UI with DV exemption" (if Employment_Status = Unemployed — looking). **What to do when you see them:** open the task → click into the related Intake → read the survivor's situation → action the task (make the call, draft the letter, send the referral) → log a Case Note documenting what you did → mark the task Complete. **Critical:** auto-tasks now appear on the Contact's Activity panel (after P0.5 fix added WhoId) — Lana doesn't need to navigate to the Intake to see them. Each task's Description field has SFTS-specific instructions (e.g., for the ID task, it mentions the fee-waiver attestation letter; for WorkOne it mentions the DV exemption flag that must be requested explicitly).
**Current state:** Pipeline LIVE since Day 8. No doc explains the task pattern to Lana. She'll just see tasks appear and need to know what to do.

### C4. Email alert handling 🔴
**Plan:** When a new web intake lands, an email goes to BOTH director@sftsinc.com and clientadvocate@sftsinc.com with: subject "New SFTS web intake — [Risk Level] risk — [Intake Name]", body containing Risk_Level / Shelter_Requested / Children_Present / Number_of_Children / abuser_nearby / weapons_in_home flags + deep link to the Intake. **Decision tree:** if Risk = High AND it's during business hours → call within 15 min. If Risk = High AND off-hours → call within 1 hour (still). If Risk = Medium → call same day. If Risk = Low → call within 24h. **First call protocol:** check Phone_Safe_To_Return; if true, call. If false, send a careful email or text (never identify SFTS unless survivor confirmed safe). Document the attempt in a Case Note even if no answer.
**Current state:** Email pipeline LIVE. Decision tree is in Lana's head, not on paper.

### C5. Mandatory Report filing decision tree 🟡
**Plan:** Indiana mandated-reporter law requires reports to DCS (suspected child abuse/neglect, including witnessed DV with kids present), APS (adult protective — elderly/disabled at risk), Law Enforcement (imminent threat). **Trigger checklist:** survivor disclosed → minor child witnessed violence? = DCS report. Survivor's child has visible injury or disclosure? = DCS report + LE if recent. Elderly or disabled adult at risk = APS report. Imminent threat to anyone = LE 911. **Where to log it:** open the source Hotline_Call → check Mandatory_Report_Triggered (auto-posts Chatter alert). Then App Launcher → Mandatory Reports → New → fill: Report_Type, Report_DateTime, About_Contact, Reporting_Agency_Name, Method (Phone/Online/Fax), Triggering_Event, Narrative (what you reported, verbatim if possible), Outcome_Status starts "Awaiting Response". Update Outcome_Status when agency responds. **Audit trail:** these records are subpoenable — be precise, factual, no editorializing.
**Current state:** Object live. Advocate quickref has the mechanical "how to file" but not the decision tree for *when* to file.

### C6. Referral tracking 🔴
**Plan:** When SFTS sends a survivor to an outside agency (legal aid, Medicaid office, WorkOne, Brightpoint, etc.), create a Referral__c. Fields: Contact (the survivor), Referral_Date, Referred_To_Agency (text — or pick from SFTS_Resource catalog via Resource lookup), Referred_To_Phone, Referral_Type (Legal / Housing / Financial / Medical / Mental_Health / Other), Reason (why we're referring), Status (Sent / Survivor_Contacted_Agency / Appointment_Scheduled / Completed / Declined), Outcome (long text — what happened). **The point:** measure follow-through. Foundation grants increasingly ask "of survivors you referred to X, what % followed through?" — Referral records answer that.
**Current state:** Object live but layout missing 5 fields (P1.5). No doc explains when to create one vs just mentioning it in a Case Note.

---

## D. Shelter operations workflows

### D1. Shelter admission ✅
**Plan:** From Contact: New → Shelter Stay → Check_In_DateTime = NOW → Status = Active → Number_of_Adults / Number_of_Children / Pets → save. Auto-Flow advances the linked Intake's Stage from "Not Started" to "In Progress".
**Current state:** Covered in advocate quickref. Manus: minor polish; expand on bed assignment when we build Bed Management in Phase 4.

### D2. Active shelter stay (daily operations) 🔴
**Plan:** While a survivor is in shelter, log: every Case Note as they happen, daily Service_Episode for "Shelter_Bed_Night" (advocate or system can batch these weekly — TBD), SSM at the appropriate checkpoint, Financial Counseling at the appropriate checkpoint, Referrals as sent. **Currently in Shelter** list view on Home page surfaces the active roster. **Daily routine:** open the list view, scan for anyone with Days_Since_Last_Contact > 3 (red flag — re-engage), check the day's auto-tasks.
**Current state:** List view exists. Daily routine isn't documented anywhere.

### D3. Shelter exit ✅
**Plan:** Open the Shelter_Stay record → Status = Exited (or Transferred / No_Show) → Check_Out_DateTime → Exit_Destination (VOCA-required: Own_Apartment / Family / Friends / Transitional_Housing / Hotel / Other_Shelter / Returned_To_Abuser / Homeless / Hospital / Unknown / Other) → Exit_Reason (Goals_Met / Rules_Violation / Max_Stay / Voluntary / Medical / Other) → save. Length_of_Stay_Days auto-calculates.
**Current state:** Covered in advocate quickref. Manus: minor polish on Exit_Destination decision tree.

### D4. Discharge / case closure 🔴
**Plan:** When survivor exits the program (whether or not she was in shelter): (1) Final SSM at Checkpoint = Discharge. (2) Final Financial_Counseling at Checkpoint = Discharge if applicable. (3) Final Case_Plan status = Completed if applicable. (4) Close the caseman__Intake__c — set Stage = Closed, Result = appropriate enum, CloseDate = today, Description = brief summary of how case ended. (5) Update Contact Donor_Type if applicable (sometimes survivors become small donors after exit). **Why this matters:** open intakes count against capacity in reporting. Discharge ritual closes the loop.
**Current state:** Possible in system. Zero doc on the closure ritual.

---

## E. Case planning workflows

### E1. Case Plan creation + Case Goal hierarchy 🔴
**Plan:** Within first 30 days of intake (or first 14 days if in shelter), create a Case_Plan__c on the Contact. One Plan per active case. Fields: Plan_Date (today), Plan_Status (Active / On_Hold / Completed / Abandoned), Author (the lead advocate), Target_Exit_Date (when survivor and advocate think she'll achieve plan goals), Plan_Notes (executive summary). Then create 3-7 Case_Goal__c records (master-detail child of the Plan). Each Goal: SMART format (Specific / Measurable / Achievable / Relevant / Time-bound), Status (Not_Started / In_Progress / Achieved / Adjusted / Abandoned), Target_Date, Notes. Review monthly with survivor; update Status as goals progress.
**Current state:** Objects + master-detail wired. Layout fixes pending (P1.6). Zero doc on the methodology — what good SMART goals look like for DV survivors, how to phrase non-prescriptively.

---

## F. Fundraising workflows

### F1. Donation entry 🔴
**Plan:** Donations arrive via mail (check), online (Stripe/PayPal/Donorbox — not yet integrated), in-person at events, or via designated funds (Combined Federal Campaign etc.). **Manual entry:** Donor (Contact lookup — search by name; create new Contact if needed with Donor_Type=Individual/Corporate/Foundation), Donation_Date (date received), Amount, Donation_Type (Cash / Check / Credit_Card / In_Kind / Stock / Other), Designated_For (General_Operating / Shelter / Children / Education / Capital / Memorial / Specific_Event), Notes (memo line, batch ID, in-memory-of language). Mark Acknowledgment_Sent = unchecked initially.
**Current state:** Object live. No doc on entry conventions, donor lookup-vs-create rules, batch-day workflow.

### F2. Donor acknowledgment letter 🔴
**Plan:** **Currently manual.** Lana exports a weekly list of donations where Acknowledgment_Sent = unchecked → drafts thank-you letters → mails them → flips the checkbox. **Phase 2 plan:** auto-generated PDF acknowledgment letter Flow on Donation insert (template letter, merge fields, attach to Donation record); Lana reviews + sends from Salesforce; checkbox flips automatically. Until that's built, document the manual weekly batch.
**Current state:** Manual. Nothing built or documented.

### F3. Fundraising Event setup 🔴
**Plan:** Create Fundraising_Event__c (Name, Event_Date, Venue, Goal_Amount, Status, etc.). Then create child Sponsorship_Tier__c records (Tier_Name, Tier_Amount, Benefits, Max_Sponsors). When a donor commits to a tier, create a Donation linked to the Event AND mark it against the appropriate Tier (need a Sponsorship junction object — Tier 2 build, not yet started). Net_Revenue auto-calculates on the Event.
**Current state:** Event + Tier objects live. Sponsorship junction NOT built. No doc on the workflow.

### F4. Grant pipeline 🔴
**Plan:** One Grant__c per funder application. Stages: Identified → Researching → Drafting → Submitted → Awarded (or Declined) → Reporting → Closed. Fields capture Amount_Requested, Amount_Awarded, Reporting_Due_Date, Reporting_Frequency, Funder_Contact_Person, Application_Deadline, Award_Date, Performance_Metrics. **Critical:** Reporting_Due_Date drives deadline alerts (Phase 2 Flow not yet built). For now, Lana watches manually.
**Current state:** Object live with rich fields. Zero workflow doc. This is the most operationally-critical fundraising doc — grants pay the bills.

---

## G. Cross-cutting / admin workflows

### G1. New advocate onboarding 🔴
**Plan:** (1) Create User record in Setup → Users → New User. (2) Assign permsets: SFTS_Build_All_Access (admin only) OR SFTS_Advocate (frontline) OR SFTS_Fundraiser (fundraising only). Both Lana + Brittany have all three; future advocates likely just SFTS_Advocate. (3) Verify they can see SFTS Operations app via App Launcher. (4) Have them log in, change password, set MFA. (5) Walk them through docs/13-training-scenarios.md with the 5 training survivors. (6) Assign first real case alongside Lana for shadow week.
**Current state:** Permsets live. No onboarding checklist exists.

### G2. Permission troubleshooting 🟡
**Plan:** Lana says "I can't see X" → check (a) does she have the right permset? Setup → Users → Lana → Permission Set Assignments. (b) does the permset grant FLS on that field? (c) is there a sharing rule covering the record? (d) is the layout hiding the field even though FLS is open? (e) is the Lightning App showing the right tab?
**Current state:** Discovered the hard way during Day 7. Some patterns captured in docs/00-decisions.md but not in a "if survivor says X, check Y" troubleshooting guide.

### G3. Training data cleanup 🔴
**Plan:** After Lana + Brittany are comfortable, delete the 44 TRAINING records. **Order matters:** delete child records before parents (Case_Goals before Case_Plans, Service_Episodes before Contacts, etc.). Use the "TRAINING" list view filters where they exist; otherwise SOQL via Developer Console. Better long-term: a "Hide TRAINING records" list view filter (P2.1) so they stay invisible without being deleted.
**Current state:** Records loaded. No cleanup doc.

### G4. Daily handoff / shift change 🔴
**Plan:** When a shift ends, advocate (a) ensures every interaction has a Case Note, (b) ensures every billable service has a Service_Episode, (c) checks "Open Calls Today" list view = empty (all callbacks done or rescheduled), (d) checks her Tasks for any due-tomorrow items, (e) optionally posts a brief shift summary as Chatter on the relevant Contacts.
**Current state:** Implicit. Not written down.

---

## H. What Manus should produce

For each ✅ workflow: light polish, ensure consistency of terminology.
For each 🟡 workflow: expand the missing pieces (decision trees, the *when* and *why* not just the *what*).
For each 🔴 workflow: write the doc from scratch using the plan summary above as the starting point.

**Format Manus should follow per workflow:**
1. **One-line summary** ("This is what this workflow accomplishes.")
2. **When to use it / When NOT to use it** (decision triggers)
3. **Prerequisites** (what must exist before starting)
4. **Step-by-step** (numbered, with specific clicks/field names/UI elements; include screenshots placeholders if useful)
5. **Field-by-field reference** (what every field means, what values to use, examples)
6. **Common gotchas** (the things that bite you — based on what's in `docs/15-resume-point-after-day-7.md` lessons learned)
7. **What success looks like** (the record state after the workflow completes correctly)
8. **What ties to what** (cross-references to related workflows — e.g., a Case Note should usually be paired with a Service Episode)

**Tone:** trauma-informed, never patronizing, written for a smart person who's new to Salesforce. Use the same warm-handcrafted voice as the SFTS website. No corporate jargon. No "leverage" or "synergy." Just plain English with the technical specificity that gets the job done.

---

## I. Manus prompt (paste this into Manus)

> **Task: Write the SFTS Salesforce workflow documentation set.**
>
> **Context:** Shelter from the Storm, Inc. is a domestic violence shelter in Central Indiana. We've built a live Salesforce Nonprofit Cloud implementation that handles hotline calls, intakes, shelter stays, danger assessments, self-sufficiency tracking, financial counseling, case planning, referrals, mandatory reports, donations, fundraising events, and grants. The system is in production and being used by Lana Stephens (Executive Director, primary user) and Brittany (Chief of Staff). Both are new to Salesforce.
>
> **Source materials (read these first, in this order):**
> - `docs/20-workflow-docs-inventory-for-manus.md` (this file) — your master inventory
> - `docs/09-advocate-quickref.md` — existing one-page intro
> - `docs/13-training-scenarios.md` — 5 training-survivor walkthroughs
> - `docs/15-resume-point-after-day-7.md` — full state-of-the-build with lessons learned
> - `docs/19-ui-audit-gap-list.md` — current UI polish status (note where UI is rough so docs can flag workarounds)
>
> **Your job:** produce one workflow doc per entry in sections A–G of the inventory file. **Skip entries marked ✅ unless they have notes telling you to polish.** Use the per-workflow "Plan" summary as your scaffold; expand it into the 8-part format defined in section H of the inventory.
>
> **Output:** save each as a separate markdown file in `docs/workflows/` named like `A1-website-intake-followup.md`, `B2-self-sufficiency-matrix.md`, etc. Use the same letter-number scheme as the inventory.
>
> **Tone requirements:**
> - Trauma-informed: this is about survivors of domestic violence. Never minimize, never sensationalize, never make the worker feel stupid for not knowing something.
> - Plain English: a smart person who's never used Salesforce should understand every sentence. Define jargon the first time you use it.
> - Specific: name actual UI elements, field API names, button labels, list view names. "Click the + icon in the top-right" not "navigate to the action menu."
> - Warm but not saccharine. The SFTS website voice is the reference — confident, kind, grounded, not corporate.
> - Honest about gaps: when the UI is rough (per docs/19), say so and give the workaround. Don't pretend things are polished if they're not.
>
> **Don't write:**
> - Generic "Salesforce 101" introductions — assume the reader has worked through `docs/09-advocate-quickref.md` already.
> - Setup or admin instructions for things only Daniel touches (Connected Apps, deploy commands, Tooling REST PATCH). Those belong in the technical docs, not workflow docs.
> - Anything you can't verify against the source materials. If you're guessing, flag it with `**[VERIFY]**` so Daniel can confirm before the doc ships to staff.
>
> **Verify and self-check before saving each doc:**
> - Field API names match what's in `force-app/main/default/objects/<Object>/fields/`
> - Picklist values match what's in the field XML
> - Quick action names match what's in `force-app/main/default/quickActions/`
> - Cross-references to other workflow docs use the correct letter-number IDs
>
> **Deliverable order (prioritize for advocate use first):**
> 1. Section B (assessments — these are the highest-leverage outcomes work)
> 2. Section A (intake — most-common daily entry point)
> 3. Section C (daily ops)
> 4. Section D (shelter ops)
> 5. Section E (case planning)
> 6. Section F (fundraising — lower priority since Lana does these less often)
> 7. Section G (admin — lowest priority)
>
> Save a single `docs/workflows/INDEX.md` at the end listing all docs produced with their one-line summaries.
>
> If you have questions, write them to `docs/workflows/QUESTIONS-FOR-DANIEL.md` rather than guessing. Daniel will answer in batch.

---

## Quick stats

- **24 workflows total** across 7 sections
- **3 ✅ Done** (light polish only)
- **9 🟡 Partial** (expand missing pieces)
- **12 🔴 Missing** (write from scratch)
- **Highest-leverage missing docs:** B2 (SSM), B3 (FC), C3 (auto-tasks), C5 (mandatory report decision tree), F4 (grants), D4 (discharge ritual)
