# Lana Walkthrough — Meeting Follow-up Action List (2026-05-15)

**Source:** ~3.5h walkthrough call between Daniel and Lana (President/ED) + the Gemini meeting summary. This doc only captures **Salesforce / code / build** items. Personal/contract/board prep/calendar/email-migration items are flagged as "→ Manus" or "→ Daniel manual" so they're out of build scope.

**Read alongside:** [docs/19-ui-audit-gap-list.md](19-ui-audit-gap-list.md) (overnight P0–P3 status), [docs/20-workflow-docs-inventory-for-manus.md](20-workflow-docs-inventory-for-manus.md), [docs/21-day-8-overnight-push-wrap.md](21-day-8-overnight-push-wrap.md).

---

## Status legend
- ✅ **Done** — already shipped (overnight push or earlier)
- 🟢 **Validated by Lana** — she saw it work in the walkthrough
- 🔨 **In queue (technical)** — me to build/fix
- 🟡 **Needs Lana input first** — blocked on her feedback before I can act
- 📤 **Manus** — research, orchestration, drafting, scheduling
- 👤 **Daniel manual** — contract, board prep, in-person tasks
- 🧑‍🎓 **Lana homework** — her own action items

---

## A. What Lana validated working in the walkthrough

These came up in the walkthrough and Lana saw them work as built. Already shipped — no action needed except keep doing what we're doing.

- ✅🟢 Auto-tasks fire on web intake (ID replacement, Medicaid application, WorkOne) — confirmed when she submitted a test intake
- ✅🟢 Case Notes log with timestamps, confidential flag, duration — demoed via the "Log Case Note" pattern
- ✅🟢 VOCA eligibility checkbox on Service Episodes — surfaced in the demo
- ✅🟢 Shelter Stay tracking (length of stay auto-calculates) — Lana confirmed seeing days count up correctly
- ✅🟢 Self-Sufficiency Matrix scoring across 10 domains — Lana walked through what each score means; confirmed "I COULD USE THAT MID ONE SEVERAL TIMES" — yes, multiple mid-program checkpoints supported
- ✅🟢 Danger Assessment scoring + tier auto-calc — surfaced extreme danger tier on test record
- ✅🟢 Referrals + Resources catalog — Lana saw she can add a new resource easily; agencies' contact info, links, eligibility notes all there
- ✅🟢 Programs catalog (financial literacy, self-sufficiency coaching, etc.) — shown
- ✅🟢 Per-object Log_Case_Note quick actions on Hotline_Call / Shelter_Stay / FC / SSM (P2.3 from overnight) — usable now, Lana saw the FC version
- ✅🟢 Home page surfacing today's calls / current shelter / mandatory reports / high-risk DAs — she saw the operational dashboard
- ✅🟢 Web intake → email alert + intake record + Owner=Lana + auto-tasks pipeline — she submitted a test and it worked

---

## B. Technical to-do — Build queue (Salesforce/code work for me)

Items I should knock out, ordered by priority. Each maps to a transcript moment.

### B1. 🔨 Web form: email validation + redirect on failure
**Context:** Lana submitted a test intake with a space in her email and the form silently rejected it (didn't send anything to Salesforce).
> *"add a flag and a redirect back to the field that's missing... they're not gonna be able to figure that out"*
**Fix:** In `sfts-site/get-help.html` + `netlify/functions/salesforce-intake.js` — trim whitespace from email field on submit; if validation fails, scroll user back to the field with a visible error message rather than silently failing. Same pattern for any required field that fails server-side validation.
**Effort:** ~30 min. Pure JS. Test by deliberately leaving fields invalid.

### B2. 🔨 Web form: handle first-name-only intake more gracefully
**Context:** Current workaround doubles the first name when only first name provided (because Salesforce Contact requires a Name and the Name field is the doubled value).
> *"This will... double their name. because it wants a name in Salesforce... we can fix this once we go back in there"*
**Fix:** In Netlify Function, when only first name provided, set `LastName = "(unknown)"` instead of duplicating the first name. Then a Case Note can be added later when full name surfaces. Less clutter.
**Effort:** ~15 min in the JS payload mapping.

### B3. 🔨 Investigate $360 caseman managed package — refund pursuit
**Context:** Daniel discovered SFTS pays $360/year for a "case management" managed package. Wants to confirm nothing critical depends on it and pursue a refund.
> *"so make sure that nothing that we've built is using this managed package. And then get a refund for this."*
**Reality check:** Our entire intake flow runs on `caseman__Intake__c`, which IS a package object. Need to determine whether `caseman__Intake__c` is in the FREE Power of Us Edition or the PAID add-on. Likely it's the paid one — we may have built ourselves into a paid dependency.
**Investigation steps:**
1. Setup → Installed Packages → identify which package owns `caseman__Intake__c`
2. Check whether that package is the $360 SKU or a different one
3. If it IS the $360 SKU, options: (a) accept the cost, (b) build our own Intake__c custom object and migrate data + flows + integration (heavy lift, ~1 day), (c) verify Power of Us covers nonprofits with the case management package free
4. Open a Salesforce support case to clarify pricing under Power of Us
**Effort:** 1–2 hours investigation, then either 0 (free under POU) or 8+ hours (custom object migration). **HIGH PRIORITY — financial impact.**

### B4. 🔨 Search functionality — fix global search not surfacing custom-object records
**Context:** When Lana typed "case plans" into global search, nothing came up. When she searched "test test" or her name, only some records surfaced.
> *"I'll add that to my list to investigate what the search parameters are and what they're actually attaching to to make that a little bit more functional."*
**Fix:** Setup → Search Settings → ensure all SFTS custom objects (Case_Plan__c, Case_Note__c, Service_Episode__c, etc.) are toggled ON for global search. Check whether the HIPAA-protective permsets have FLS gaps that prevent searched fields from being indexed for the running user. Verify search index isn't filtered by the pmdm `IsClient__c` flag inadvertently.
**Effort:** ~1 hour of investigation + permset audit + possible deploy.

### B5. 🔨 Reorder SFTS Operations app tabs to follow Lana's workflow
**Context:** Daniel said he can reorder tabs to mirror the actual workflow sequence.
> *"I can reorder those things across the top where it's like hotline calls, contacts, shelter stays. I can kind of follow your process. ... we have to define what that actual process looks like before I can put it in that order."*
**Status:** 🟡 Blocked — waiting on Lana's "this is my actual order" feedback in one of her exploration sessions (B23 below).
**Once we have it:** ~10 min metadata edit on `SFTS_Operations.app-meta.xml`.

### B6. 🔨 Audit + expand Event_Type picklist on Fundraising_Event__c
**Context:** Lana asked if she could add to event types. Daniel: "make a mental note to make sure that this list is pretty much all inclusive."
**Action:** Pull current picklist values; add anything missing for SFTS-specific events (Cowboy Ball, Plant Bingo, Annual Gala, Awareness Walk, etc.). Possibly remove "Annual Cowboy Ball" auto-prefix since it's been held only once — let label be flexible.
**Effort:** ~15 min metadata.

### B7. 🔨 Add Stay_Type__c picklist on Shelter_Stay__c
**Context:** Lana noted SFTS uses both owned shelter housing AND hotel placements. Currently no field distinguishes them, so reporting can't separate them.
> *"well, maybe in the shelter stay there could be two different ones. We can create other categories."*
**Fix:** Add `Stay_Type__c` picklist on Shelter_Stay__c with values: `SFTS Owned Housing`, `Hotel — SFTS Paid`, `Partner Shelter`, `Transitional Housing — SFTS Paid`, `Other`. Update layout. Update reports later to break out by type.
**Effort:** ~30 min (field + layout + permset FLS).

### B8. 🔨 Concurrent-edit warning on records
**Context:** Lana asked: if Brittany and I open the same record at the same time, will I see she's working on it?
> *"make a note here just to make sure that there does. That if you do try to open up the same record, whether it shows that like it's being edited by someone shows up as a flag, I can I can make that adjustment."*
**Fix:** Salesforce has built-in "Lightning Page Bell" / "Now Viewing" indicators when multiple users view the same record. Verify it's enabled at the org level (Setup → Activity Settings → Show "Now Viewing"). If not enabled, turn it on. If it doesn't fire on auto-task creation, may need a Flow that posts a Chatter notification.
**Effort:** ~30 min investigation; org setting toggle most likely.

### B9. 🔨 Mandatory Report — define triggering events as a picklist
**Context:** Daniel mentioned Mandatory Report triggering needs to be defined so it's not subjective per advocate.
> *"What... What are the triggering events that's going to say, I'm calling DCS right now?... I don't want this to be just... It's completely subjective every time"*
**Fix:** Define a `Triggering_Event__c` picklist on Mandatory_Report__c (currently a text field) with controlled values: `Minor child witnessed violence`, `Minor child has visible injury`, `Minor child disclosed abuse`, `Elderly/disabled adult at risk`, `Imminent threat to anyone`, `Court-ordered disclosure`, `Other`. Pair with workflow doc C5 (already in docs/20).
**Effort:** ~30 min schema + layout + workflow doc update.

### B10. 🔨 Text-thread deletion guidance — copy-paste template for survivors
**Context:** Lana wants to be able to quickly send a survivor instructions on how to delete the SMS thread (in case the abuser checks their phone).
> *"I want to be able to tell them how to do that quickly... so that they... there's not something on their phone somebody can look at."*
**Implementation options:**
- Easiest: add as a special record in `SFTS_Resource__c` with category "Communication Safety" and the full Android + iOS deletion instructions in `Description__c`. Lana copies → pastes into text.
- Better: add a Lightning Quick Action on Hotline_Call (or Contact) called "Copy Safety Text" that copies a pre-written multi-line string to clipboard. Requires a small Lightning Web Component.
**Recommendation:** Start with the Resource catalog approach (15 min). Upgrade to LWC later if Lana wants it as one-click.
**Effort:** 15 min (Resource record) or 2 hours (LWC).

### B11. 🔨 Owner ID display UX on auto-created records
**Context:** Lana saw "Contact owner: Daniel Stephens" on an auto-created intake and asked what that meant. Even though we set OwnerId = Lana in payload, Created_By = Daniel (the integration user / deploying admin). Confusing.
**Fix:** On Contact + caseman__Intake__c layouts, label OwnerId as "Assigned Advocate" via field-level help text or a Translation Workbench override. Hide CreatedById from the main highlights. Make Owner more prominent. Already in P0.4 layout but worth a polish pass.
**Effort:** ~30 min metadata.

### B12. 🔨 Hotline_Call concept rework
**Context:** Daniel realized SFTS doesn't operate a true 24/7 hotline — they have a number people can call.
> *"I'm thinking about changing this one a little bit because you don't really operate with a hotline you just have a number that they can call... I want to see if I can change this a little bit and figure out if there's a better way for us to to do this"*
**Options:**
- A. Rename `Hotline_Call__c` → `Initial_Contact__c` (label only — API name stays for stability). Cosmetic.
- B. Keep Hotline_Call__c as a "Phone Conversation" event, redefine the use case in workflow docs (no schema change).
- C. Merge into a new Initial_Contact__c that covers phone + email + walk-in (heavy refactor).
**Recommendation:** B + relabeling. Don't refactor a working object.
**Effort:** ~30 min layout + tab label changes + workflow doc update.

### B13. 🔨 Hotel-stay CYA contract — generate on Shelter_Stay create
**Context:** Daniel noted that even hotel placements need a contract for SFTS protection.
> *"anytime that you're bringing someone into any of the emergency housing, even if it's not housing that you own, you're still going to want that as a CYA"*
**Fix:** Build a Salesforce document-merge template that generates a PDF "Emergency Housing Agreement" pre-filled with the resident's name, dates, location (own shelter or hotel), and the standard rules. Attach to the Shelter_Stay record on save. Lana prints + has resident sign + uploads scan.
**Implementation:** Use Conga Composer (paid, easy) OR build a Visualforce PDF page (free, more setup). Recommend Visualforce route to keep $0 added cost.
**Effort:** 3–4 hours for the template + Quick Action that generates it.

### B14. 🔨 Resource link verification — automated check
**Context:** Daniel mentioned checking that links in `SFTS_Resource__c.Apply_URL__c` still work, since agencies update their websites.
**Fix:** Build a scheduled Flow (weekly) that hits each `Apply_URL__c` via an HTTP callout, marks `Link_Last_Verified__c` = today and `Link_Status__c` = OK/Broken. Surface broken links in a list view.
**New schema:** add `Link_Last_Verified__c` (Date), `Link_Status__c` (Picklist: OK / Broken / Not Checked) on SFTS_Resource__c.
**Effort:** ~2 hours (HTTP callout flows are fiddly; may need an Apex helper if Salesforce can't do it natively from Flow).

### B15. 🔨 Board member task assignment UI
**Context:** Lana asked if she could assign tasks to specific board members and have them see/track them.
> *"Like one of the board members, they've said they can help with something and I can assign them a task"*
**Fix:** Standard Salesforce Tasks already do this. Need to:
1. Set up board members as Salesforce Users (use the spare Power of Us licenses — 10 free, currently using ~3)
2. Build a "Board Volunteer" permset (read-only on most objects, edit on Tasks they own)
3. Add a "Board Tasks" list view on the Tasks tab grouped by Owner
4. Build a "Assign Task to Board Member" quick action on a Board Member contact record (or a custom Board_Member__c object)
**Effort:** ~3 hours (permset + UI + maybe a small Board_Member__c object).

### B16. 🔨 Recurring touch-base reminders for board member tasks
**Context:** Lana wants to keep board members accountable on what they've committed to.
**Fix:** When a Task is assigned to a board member and marked recurring (e.g., monthly), generate a Calendar Event AND send an email reminder 24h before. Salesforce has built-in recurring Tasks, but the email reminder layer is a small Flow.
**Effort:** ~1 hour after B15 lands.

### B17. 🔨 Donor acknowledgment letter — automated generation
**Context:** IRS requires written acknowledgment for donations >$250. Lana doesn't have a system; this needs to be built.
> *"I looked at some IRS type requirements for nonprofits... they want like acknowledgements"*
**Fix:** Same pattern as B13 — Visualforce PDF template generated on Donation__c create (or a button), attached to the record, marked Acknowledgment_Sent__c = true. Bonus: scheduled Flow auto-emails the donor with the PDF attached.
**Effort:** ~3 hours.

### B18. 🔨 Fact-sheet export for grant applications
**Context:** Lana wants to click one button and get an updated fact sheet (numbers compiled fresh) for grant applications.
> *"a fact sheet with updated numbers that I don't have to like go back and compile. I don't have to work for that. It's just already a report. I just click the download button."*
**Fix:** Build a single-page Visualforce or Lightning component that pulls live counts:
- Total survivors served YTD / lifetime
- Total shelter nights provided YTD / lifetime
- Total hotline calls YTD / lifetime
- Total VOCA-eligible service hours YTD
- Top 3 service categories by hours
- Total raised YTD / lifetime
- Average length of stay
Render as PDF on demand via a Quick Action.
**Effort:** ~4–6 hours.

### B19. 🔨 Weekly grant rhythm dashboard
**Context:** Lana needs a 3-hr/week grant focus. The dashboard should show "where am I on every grant?"
> *"I want to have is this is just the report view of it, like the dashboard view of it. But I want them to be able to actually come up and say, I want to be able to go through every single one and be like, OK, this one, this one. this is the status on every single one"*
**Fix:** Build dashboard `D-Grants` with components:
- Open grants (Status IN Identified, Researching, Drafting, Submitted)
- Grants closing in next 30 days
- Grants closing in next 90 days
- Grants awaiting reporting (Reporting_Due_Date in next 60 days)
- Grants awarded YTD with $ totals
- Lapsed grants (no activity in 30 days, status not Closed)
**Note:** Per docs/14, reports must be UI-built. So this is partially blocked on getting the report set built first (P3.1 in docs/19).
**Effort:** ~2 hours after underlying reports exist.

### B20. 🔨 Brittany onboarding — user setup + permset
**Context:** Daniel committed to training Brittany on case management as part of the contract.
**Fix:**
1. Setup → Users → New User: clientadvocate@sftsinc.com (already exists per docs/15) — verify she's active, has SFTS_Advocate permset assigned
2. Confirm she can log in and see SFTS Operations app
3. Build a "Brittany walkthrough" sub-doc derived from docs/13 training scenarios
**Effort:** ~30 min Salesforce setup; training is a separate live session.

### B21. 🔨 TRAINING records cleanup workflow
**Context:** 44 TRAINING records in prod. Lana mentioned needing to send actual test cases without those polluting reports.
**Fix:** Build a "TRAINING_Cleanup" anonymous Apex script (run from Developer Console) that deletes all records where Name LIKE 'TRAINING%' across Contact, Hotline_Call, Shelter_Stay, Danger_Assessment, Mandatory_Report, Self_Sufficiency_Matrix, Financial_Counseling, Service_Episode, Case_Note, Case_Plan, Case_Goal, Referral, caseman__Intake. Order: child records first, then parents. Document the script.
**Effort:** ~1 hour + Lana's go-ahead before running.

### B22. 🔨 HIPAA permset audit — verify SFTS_Fundraiser has zero case access
**Context:** Lana wants donor-management volunteers to NOT see HIPAA-protected case info.
> *"User permissions can be customized to restrict access to HIPAA-protected information while allowing fundraising volunteers full access to donor management."*
**Fix:** Open SFTS_Fundraiser permset; verify:
- No object-level access to Hotline_Call, Shelter_Stay, Danger_Assessment, Mandatory_Report, Case_Note, Service_Episode, Case_Plan, Case_Goal, Referral, SSM, FC, caseman__Intake
- Contact: read-only on Donor_Type, Email, MailingAddress, Phone — NO read on VOCA fields, caseman fields, Last_Contact_Date, Days_Since_Last_Contact, Engagement Summary section
- Build a test by assigning permset to a sandbox user and confirming visibility matches
**Effort:** ~1 hour audit + possible permset edits + deploy.

---

## C. Workflow doc updates (additions to docs/20 inventory for Manus)

These came up in the walkthrough — Manus should fold them into the workflow docs queue.

- ➕ **A4 (Walk-in workflow)** — expand to also cover hospital / agency referral pattern (Daniel mentioned: "they got referred at a hospital... like a walk-in referral")
- ➕ **C5 (Mandatory Report)** — once B9 lands (controlled triggering picklist), update workflow doc with the decision tree
- ➕ **NEW: D5 — Hotel/Partner shelter placement** — once B7 + B13 land, document the "we're at capacity, place in hotel" workflow including contract generation
- ➕ **NEW: G5 — Whisper Flow / dictation guide for advocates** — Lana now uses Whisper Flow. Document how to use it inside Salesforce text fields (double-click Ctrl+Win, talk into a Body field, etc.). Pair with the "click into the field FIRST" gotcha that bit Lana repeatedly.
- ➕ **NEW: G6 — Text-thread safety guide for survivors** — once B10 lands, document how + when to send the deletion instructions
- ➕ **NEW: A5 — Email-only intake (B11)** — already in inventory but emphasize how the Caller_Email pathway differs

---

## D. Hand-off to Manus (research / orchestration / drafting)

Not technical build work — Manus should pick these up.

- 📤 Research **Zephy alternatives** that integrate with Salesforce for donations + event reservations. Constraints: bingo events require cash/debit only (Indiana gaming reg — credit cards prohibited). Look at: Stripe + Salesforce native, Donorbox, Givebutter, Givelify, Salesforce Nonprofit Cloud Fundraising add-on (paid).
- 📤 Draft **$2,500 quarterly contract proposal** for Daniel's services. Include: scope (24/7 access, Brittany training, full Lana training, ongoing support), fair market value (~$35k), in-kind donation differential. Manus has the meeting context.
- 📤 Draft **fair market value documentation** showing what comparable Salesforce architect / nonprofit ops consultant rates would charge (Indianapolis market, hourly + project-based comps).
- 📤 **Schedule weekly touch-base meetings** in Daniel's calendar:
    - Grants (1hr)
    - Operations (1hr)
    - Case Management (1hr)
    - File Digitization (1hr)
- 📤 **Send meeting invites** to Lana for Wed/Thu/Fri next week (after Cincinnati Tuesday).
- 📤 **Calendar block** for Daniel's June 15 board presentation prep (~3 hours).
- 📤 **Subscription audit** — comb Daniel's QuickBooks for recurring expenses to identify what SFTS is paying for that may be redundant (the $360 Salesforce one being the first known target).
- 📤 **Outlook → Gmail migration plan** for Lana — drafting the steps doc; identify what email history is worth preserving + script to bulk-import.
- 📤 **File digitization workflow proposal** — Lana has paper files; build a process for scanning + uploading + linking to Salesforce records. Recommend tool, scanning order, naming convention.
- 📤 **Grant inventory + deadline tracker** — research current open grants for DV shelters in Indiana, build the inventory in Salesforce or Notion. VOCA cycle (closed 3/11) means next opens ~3/2027 — long-tail. Prioritize foundation grants opening Q3-Q4 2026.

---

## E. Daniel manual / personal action

- 👤 Investigate $360 caseman charge with Salesforce Support (parallel to B3 build investigation) — request refund if unused.
- 👤 Prepare 20–25 min board presentation for **June 15, 2026** meeting. Demo + ask + 5-year vision.
- 👤 Train Brittany on case management (live session, after B20 sets up her access).
- 👤 Final review of contract proposal Manus drafts before sending to Lana.
- 👤 Decide whether to migrate caseman__Intake to a custom object (depends on B3 outcome).

---

## F. Lana homework

- 🧑‍🎓 Explore Salesforce — minimum **2-3 sessions of 30+ minutes**, Whisper-Flow-record her thoughts, send transcripts to Daniel. Especially:
    - What tab order should the SFTS Operations app follow? (unblocks B5)
    - What fields does she scan first when she opens an intake? (unblocks P3.3 custom Intake page)
    - What's missing from the resource catalog?
    - What event types are missing? (informs B6)
- 🧑‍🎓 Schedule meeting Wed/Thu/Fri next week.
- 🧑‍🎓 Send Daniel any new resources / agencies as she encounters them — he'll add to SFTS_Resource__c.

---

## G. Priority order for technical work (next session)

If I have ~6 hours autonomous build time, this is the order:

1. **B1 + B2** (web form fixes) — 45 min — pure JS, immediate user-facing wins
2. **B3** (caseman package investigation) — 1–2 hr — financial impact
3. **B4** (search functionality) — 1 hr — Lana keeps hitting this
4. **B6 + B7 + B11** (Event_Type audit + Stay_Type field + Owner UX polish) — 90 min — small metadata wins
5. **B9 + B12** (Mandatory_Report triggering picklist + Hotline_Call relabel) — 1 hr — clarity wins
6. **B10** (text-thread deletion as Resource record) — 15 min — Lana wants this for in-flight conversations
7. **B22** (HIPAA permset audit) — 1 hr — compliance
8. **B8** (concurrent edit warning org-setting check) — 30 min

That's ~7 hours and hits everything urgent. The bigger items (B13 contract gen, B17 acknowledgment letters, B18 fact sheet, B19 grant dashboard) are 3–6 hours each and warrant their own sessions.

---

## Quick stats

- **22 build items** parsed from the meeting (B1–B22)
- **6 workflow doc additions** for Manus (C section)
- **9 hand-offs** to Manus (D section)
- **5 manual** items for Daniel (E section)
- **3 explicit asks** for Lana (F section)

**Highest-leverage immediate wins:** B1 (form bug), B2 (name doubling), B3 (refund), B4 (search), B10 (safety text template).
