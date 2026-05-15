# UI Audit Gap List — Day 8 Walkthrough

**Purpose:** Master list of every visual/UX gap found in the tab-by-tab walkthrough on 2026-05-15 (Daniel + Claude). Used as the fix backlog for the next build session.

**Method:** Daniel navigated each tab in the SFTS Operations app left-to-right. For each, we audited the list view, then a representative record page, then the Related tab. Gaps were noted in real time.

**The big pattern:** every Day-7 and Phase-1 custom object was built with thorough metadata (objects, fields, sharing, list views) but the **page layouts hide about half the fields**. Salesforce auto-generated minimal layouts on first deploy and we never customized them.

---

## P0 — Blocking advocate workflow

**✅ ALL P0 ITEMS SHIPPED 2026-05-15 (overnight push).** Deployed to dev + prod, both Intake Flows reactivated to new versions in prod via Tooling REST PATCH.

These prevent core daily use. Fix first.

### P0.1 — Case Note Body is invisible on the record page
Case Note record page shows Name / Contact / Date / Type only. The `Body__c` field (the actual note text!) is **hidden**. Advocates can write notes but never see them again without clicking Edit. → Layout fix: add Body, Subject, Duration, Advocate, Confidential, Intake to the Case_Note__c layout.

### P0.2 — SSM record page hides 8 of 10 domain scores
Only Safety and Housing show (in highlights). Employment_Income, Food, Health_Coverage, Mental_Health, Substance_Use, Legal, Financial_Literacy, Family_Support, and Notes are all on the record but invisible. → Layout fix: add all 10 domain scores + Notes to the Self_Sufficiency_Matrix__c layout.

### P0.3 — Contact Related tab missing 7+ critical SFTS related lists
Currently shows: Opportunities, Cases, Notes & Attachments, Campaign History (all irrelevant), plus Case Notes / Service Episodes / Case Plans (ours). **Missing:** caseman__Intake__c (THE case-management hub — Daniel had no way to navigate to the TEST TEST Intake from the Contact), Hotline_Calls, Shelter_Stays, Danger_Assessments, Mandatory_Reports, Financial_Counseling, Self_Sufficiency_Matrix, Referrals, Donations, Open Activities/Activity History. → Layout fix: rewrite the Contact-Contact Layout `<relatedLists>` section.

### P0.4 — Contact page hides ALL SFTS demographic fields
None of the VOCA fields (Race, Ethnicity, LEP, Disability, Sexual_Orientation), Indiana fields (County, ACP Enrolled), caseman fields (AgeCategory, Pronouns, LegalName, PreferredCommunicationMethod, EmergencyContact + Phone + Role, WatchList + WatchListDate), or our rollup fields (Last_Contact_Date, Days_Since_Last_Contact, Total_Service_Hours, Donor_Type) are on the page. → Layout fix: add SFTS demographic + rollup sections to Contact-Contact Layout.

### P0.5 — Tasks not visible on Contact's Activity panel
Auto-generated Tasks have `WhatId = Intake` but no `WhoId = Contact`. Salesforce's Activity panel on Contact only shows Tasks linked via WhoId. → Flow fix: add `WhoId = $Record.caseman__Contact__c` to all 4 Task-creation steps in Intake_New_Submission_Workflow + Intake_Auto_Task_Templates.

---

## P1 — Visible quality issues

These reduce trust and clarity but don't block work.

### P1.1 — Compact layouts unassigned on 4 custom objects
Case_Note, Service_Episode, Case_Plan, Case_Goal: highlights panel at top of record page is EMPTY because object meta has `<compactLayoutAssignment>SYSTEM</compactLayoutAssignment>` instead of pointing to our deployed custom layouts. → Metadata fix: change to `<compactLayoutAssignment>Case_Note_Compact</compactLayoutAssignment>` (etc.) on each object.

### P1.2 — Hotline Call record page missing Caller_Email + Completeness
The Caller_Email field we built (for the email-vs-phone routing) shows nowhere. Same for Completeness_Status. → Layout fix.

### P1.3 — Hotline Call Related tab completely empty
"No related lists to display." Should at minimum have Open Activities / Activity History / Files / Notes. → Layout fix.

### P1.4 — FC record page missing 4 of 8 fields
Financial_Position, Goals_and_Plan, Services_Recommended, SFTS_Impact all hidden. → Layout fix.

### P1.5 — Referral record page missing 5 fields
Status (only highlights), Outcome, Reason, Referred_To_Phone, and the new Resource__c lookup all hidden. → Layout fix.

### P1.6 — Case Plan record page missing 4 of 7 fields
Plan_Status, Target_Exit_Date, Plan_Notes, Author hidden. → Layout fix.

### P1.7 — SFTS Program record page hides ALL 6 fields
Only Program Name visible. Description, Category, Coordinator, Active, Funding_Source, Capacity all hidden despite being seeded with rich data. → Layout fix.

### P1.8 — SFTS Resource record page hides ALL 8 fields
Only Resource Name visible. Description, Eligibility_Notes, Apply_URL, Apply_Phone, Internal_Notes, Category, Agency, Active all hidden. → Layout fix.

### P1.9 — Duplicate tabs in SFTS Operations app
Remove from app: **Cases** (standard SF, not used, "New" broken), **Programs** (pmdm__Program__c — duplicates our SFTS_Programs), **Service Deliveries** (pmdm__ServiceDelivery__c — duplicates our Service_Episode__c). → CustomApplication metadata fix.

### P1.10 — Irrelevant "New Contact" / "New Opportunity" actions on every SFTS object
These show on every Day-7 + Phase-1 record page's action bar. They make no sense on a Financial Counseling Session or a Service Episode. → Layout fix per object.

---

## P2 — Workflow polish

These would meaningfully improve advocate experience but aren't blockers.

### P2.1 — No SFTS-built Contact list views
Lana would benefit from: "Survivors Needing Follow-up" (Days_Since_Last_Contact > 14), "Currently in Shelter", "High-Risk Survivors", and a "Hide TRAINING records" view for go-live. → Build 4 list views on Contact.

### P2.2 — Hotline Call list view: only Call Number column
Default "Recently Viewed" shows just one field. Need richer columns + SFTS-specific views like "Today's Calls Awaiting Callback". → Build Hotline_Call list views + compact layout.

### P2.3 — No SFTS quick actions on Hotline Call, Shelter Stay, Danger Assessment, Mandatory Report, FC, SSM, Referral, Case Note, Service Episode, Case Plan, SFTS_Program, SFTS_Resource pages
Lana can Follow/Edit/Delete/Clone — that's it. Useful additions vary by object (e.g., "Log Case Note" on most survivor objects). → Build per-object quick actions.

### P2.4 — Contact quick actions in chevron dropdown, not main bar
Log Case Note / Log Service Episode / New Case Plan are at sortOrder 37/38/39 — invisible without clicking the chevron. → Reorder via Lightning App Builder UI OR layout metadata change.

### P2.5 — Most list views (Hotline_Call, Mandatory_Report, Danger_Assessment, etc.) need pinning per-user
Rich list views exist but Salesforce defaults to "Recently Viewed". Each user has to manually pin their preferred default once. → Documentation only — Lana does this on first login.

### P2.6 — Danger Assessment 20-question layout density
All 20 lethality questions stacked vertically. Would scan better grouped by category (Physical / Coercive Control / Sexual / Stalking / Threats). → Layout reorganization, optional.

### P2.7 — Resources need contact info expansion + verification
Per Daniel's note: each of the 15 resources should have its contact info verified and possibly expanded (specific contact person at agency, hours of operation, in-person address). → Data quality task, not a build fix.

---

## P3 — Future-looking

Would unlock new capabilities but not part of fixing what we built.

### P3.1 — Reports + Dashboards not built yet
The Reports tab shows only package-installed sample reports. Dashboards tab is empty (we created folders, no content). → Phase 3 build per docs/14.

### P3.2 — Home page additions
Current Home has 4 cards (Open Calls / Currently In Shelter / Awaiting Mandatory Reports / High-Risk Assessments). Useful adds: "New web intakes last 24h", "Tasks assigned to me", "Stale cases (no contact in 14 days)". → FlexiPage edits.

### P3.3 — No FlexiPage Record Page for caseman__Intake__c
Currently using caseman package's default Intake page which hides our SFTS fields. Either edit the existing FlexiPage to add SFTS sections, OR build a new SFTS-native record page. → Heavy lift, separate session.

### P3.4 — More Task Template profiles
Current template Flow has 3 starter profiles (No ID / No Insurance / Unemployed-Looking). Doc 18 plan had ~12 profiles in mind across crisis/recently-left/info-seeker patterns. → Phase 2.5 / Phase 4.

---

## Estimated effort per priority

| Priority | Items | Estimated effort |
|---|---|---|
| P0 | 5 items | ~3 hours (mostly layout edits + 1 Flow update) |
| P1 | 10 items | ~4 hours (mostly layout edits per object) |
| P2 | 7 items | ~6 hours (new list views, compact layouts, quick actions) |
| P3 | 4 items | Multi-session (reports, dashboards, FlexiPage rebuild) |

**Recommended fix order for next session:**
1. Knock out all P0 (3 hours) — gets advocate workflow functional
2. Bundle all P1 layout fixes into 1 big metadata deploy (4 hours)
3. P2 items as we hit specific needs
4. P3 = its own arc

---

## Fix patterns to apply systematically

When we tackle layouts next session, the pattern is:
1. **Retrieve** the current layout from prod (`sf project retrieve start --metadata "Layout:Object__c-Object Layout"`)
2. **Edit** the XML to add missing fields in `<layoutSections>`, remove irrelevant fields, fix `<relatedLists>`, remove `New_Contact`/`New_Opportunity` from `<platformActionList>`
3. **Deploy** to dev → verify visually → deploy to prod

Compact layout fixes are simpler — just edit the object meta's `<compactLayoutAssignment>` element to point to our custom layout.

All of these are pure metadata changes — no Flow, no Apex, no data migration. Deploy time per layout: ~30 seconds. Most of the work is the XML edit.
