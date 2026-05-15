# UI Audit + Completeness-Flag Design

**Purpose:** Capture what's actually happening in the UI Daniel observed on Day 8 (2026-05-14 evening), plus the design for the "incompleteness flag" pattern Daniel sketched out. Discussion artifact — execute next session.

---

## What's installed (so we can talk about the same apps)

| App | Owner | Purpose |
|---|---|---|
| **SFTS Operations** | us (built Day 7) | Survivor side: hotline, intake, shelter, assessments, referrals |
| **SFTS Fundraising** | us (built Day 7) | Donor + grant + event side |
| **caseman__Case_Management** | managed package | Caseman's app — generic case management with Intake Checklist (Action Plan Templates), Intakes, Case Notes |
| **pmdm__Program_Management** | managed package | PMDM's app — program enrollment, service delivery, attendance tracking |

Plus a bunch of standard Salesforce apps (Sales, Service, Marketing, etc.) most of which we'll never use.

**Key realization:** Daniel's "case management side" and "fundraising case" wording in chat = he's bouncing between **four different apps** that all show Contact data slightly differently and have their own Home pages. The pmdm zero-count cards Daniel saw are on `caseman__CaseManagementHome`, not on our `SFTS_Operations_Home`.

---

## 1. The "two homes" problem — diagnosis

Both `SFTS_Operations.app` and `SFTS_Fundraising.app` declare:
```xml
<tabs>standard-home</tabs>
```

And separately, our FlexiPages (`SFTS_Operations_Home`, `SFTS_Fundraising_Home`) get auto-tabbed when Salesforce activates them as "App Default Home" via Lightning App Builder.

Net effect: **two Home tabs in the nav** — the standard one (which still shows Quarterly Performance / Today's Events / Today's Tasks / Recent Records / Recent Opportunities — none of which are useful for SFTS) and ours.

**Fix:** drop `<tabs>standard-home</tabs>` from both apps. Then only our FlexiPage tab remains. Single click, single home, no standard Lightning home clutter. Trivial metadata change, deploy, done.

The same `standard-home` tab is what Daniel sees on the caseman + pmdm apps too — those package apps own their tab lists, so we can't easily change them, but they shouldn't be Lana's daily working app anyway. She'll live in **SFTS Operations**.

---

## 2. SFTS Operations Home — what would make it more useful

Right now we have 4 list cards:
1. Open Calls Today (Hotline_Call)
2. Currently In Shelter (Shelter_Stay)
3. Mandatory Reports Awaiting Response
4. High Risk Danger Assessments

These are solid but they're all "show me records of type X." The Home could *also* surface:

- **What's missing/incomplete** (per the completeness flag concept below) — "Records needing follow-up info"
- **New web intakes in the last 24h** — direct from website, advocate hasn't touched yet (filter Hotline + Intake where CreatedDate = TODAY and no assigned Advocate)
- **Mine vs everyone's** toggle — advocates see "my assigned cases" and Director sees all
- **One headline KPI** — e.g., "12 active shelter stays · 4 hotline calls today · 2 mandatory reports awaiting"

Not all at once — pick one or two for the next iteration. My recommendation: add the "new web intakes (last 24h)" card and a headline-numbers strip at the top. Both are low-effort metadata.

The Quarterly Performance, Today's Events, Today's Tasks the standard home shows are tied to standard objects (Opportunity, Event, Task) that SFTS isn't really using for survivor work — they're noise.

---

## 3. SFTS Fundraising Home — looks right already

You called it out — the Fundraising Home (Upcoming Deadlines / Reporting Due Soon / Donations Awaiting Acknowledgment / Upcoming Events) IS the useful one. The "Home" next to it is the standard Lightning home that we'll drop per #1.

No content changes needed here. Just kill the duplicate tab.

---

## 4. The Case Management app Home — zero-count cards explained

`caseman__CaseManagementHome` is shipped by the caseman managed package and embeds these pmdm reports:

- **Contacts Absent for Last Svc Delivery** → reads `pmdm__ServiceDelivery__c` where `pmdm__AttendanceStatus__c = 'Absent'` for each Contact's most recent SD
- **Contacts with 3 Consecutive Absences** → reads same object
- **Contacts w/o Recent Service Deliveries** → reads same object

All three are **0** because we have **0 `pmdm__ServiceDelivery__c` records** in the org. PMDM is the attendance-tracking module for program-based nonprofits (classes, support groups, scheduled services). It's not how SFTS operates — SFTS is more "advocate works a case" than "client attends a class."

**Three options on what to do about this:**

A) **Ignore it.** Don't use the Case Management app at all. Lana lives in SFTS Operations. The pmdm zero cards are invisible to her.
B) **Actually use pmdm.** Start logging service deliveries (counseling sessions, court accompaniment, hotline calls, etc. as SDs against a Program). Then the cards populate and you get attendance/no-show tracking for free. Big workflow change.
C) **Use pmdm lightly.** Only log SDs for *recurring* services (like a weekly support group if SFTS runs one). Crisis calls/intakes stay on the Hotline_Call / Intake objects.

My read: (A) for now, (C) later if SFTS adds a recurring program (support group, financial literacy class). (B) is a heavier lift than the current build can absorb.

---

## 5. The Intake Checklist dropdown — why it won't click

The "Select Checklist" dropdown on Intake is the `caseman__ActionPlanTemplateGroup__c` lookup. It's not broken — it's **empty**. caseman ships the framework but doesn't ship the templates. You have to define them.

**To make the dropdown clickable:** Setup → Object Manager → **Action Plan Template Group** → New, name one (e.g., "SFTS Crisis Intake"). Then create **Action Plan Templates** under it (e.g., "1. Safety check completed", "2. Resources mailed", "3. 24-hour follow-up call placed"). When advocates open an Intake, they pick a template group, the template's items get auto-created as tasks against the Intake.

This is a per-org configuration step that's worth a workshop with Lana — she'd know what checklist items advocates actually follow. Recommend deferring until after dashboards are built (lower priority than reporting).

---

## 6. Bulk Service Deliveries, Calendar, Case Plans/Assessments/Services

These are all **pmdm + caseman package features** that live behind tabs in those packaged apps:

- **Calendar** → standard SF calendar; pmdm overlays service delivery events on it
- **Bulk Service Deliveries** → pmdm utility for entering attendance for a whole roster at once (a "20 people attended yesterday's support group" workflow)
- **Case Plans / Assessments / Services** → caseman objects for structured case management

We didn't add tabs for these in SFTS Operations because we **built parallel objects** (Self_Sufficiency_Matrix__c, Financial_Counseling__c, Referral__c) tailored to SFTS workflows. Adding caseman's tabs alongside ours would create confusion — "do I log a service delivery here or there?"

**Recommend:** stay with SFTS-native objects for now. Revisit if you want to absorb the caseman/pmdm objects' richer functionality (e.g., pmdm's Program → ProgramEngagement → ServiceDelivery hierarchy is solid for grant-required outcome reporting). That's a separate design conversation.

---

## 7. The "March reports" question

The Reports tab "Recent" sort shows 18 reports from the caseman + pmdm packages (installed March 2026) plus 35 Salesforce default "Sample Report: X" reports. None of which we created.

**What to do:**
- Salesforce doesn't allow deleting managed-package reports (they get restored on package upgrade)
- You **can** hide the "Public Reports" and "Case Management Reports" / "Program Management Embedded Reports" folders from the picker — Reports → Folders → click each → "Folder visibility" → uncheck for relevant profiles/users
- Or just let Lana favorite the SFTS reports we'll build and use "All Favorites" as her default filter

I'd just let Lana filter on the "SFTS Operations" / "SFTS Fundraising" folders once they have reports in them. Less cleanup work than hiding 53 individual things.

---

## 8. Completeness-flag pattern (the big design ask)

You sketched this beautifully:

> *I just need something. I think we need to have something that is flagged inside of salesforce that flags when something is incomplete so that we know we need to get that answer... The case manager doesn't have to be held up by one missing thing. We need a flag that it is missing and be very clear about what's missing. We should be able to click on the flag for what's missing and it takes you right to the thing that's missing.*

This is a real UX pattern. Three implementation tiers:

### Tier 1 — Formula field (1 hour, no code)

Add a formula field per record type that returns a human-readable list of what's blank. Example for `caseman__Intake__c`:

```
IF(ISBLANK(Risk_Level__c), "⚠ Risk Level · ", "") &
IF(ISBLANK(caseman__Description__c), "⚠ Situation description · ", "") &
IF(ISBLANK(Referral_Source__c), "⚠ Referral source · ", "") &
IF(NOT(Children_Present__c) && ISBLANK(Number_of_Children__c), "⚠ Children count · ", "") &
...
```

Returns: `"⚠ Risk Level · ⚠ Referral source · "` or `""` (empty = complete).

- Add to compact layout → shows in record header
- Add a sister "Completeness_Status__c" formula returning a single emoji: `"✓ Complete"` or `"⚠ Needs review"`  
- Now: list views can filter "show me all Intakes where Completeness_Status = '⚠ Needs review'" — instant queue of records-needing-attention

**Doesn't give click-to-jump** but does give clarity on what's missing in plain English right on the record. ~80% of the value at ~10% of the cost.

### Tier 2 — Lightning Web Component with click-to-jump (1-2 sessions)

Custom LWC `incompletenessChecker` on the record page. For each missing field:
- Renders a clickable warning chip with field label
- Clicking the chip programmatically opens that field for inline edit (Lightning Data Service can scroll-into-view + activate edit mode)

Config:
- One LWC, configurable per object via a Custom Metadata Type (`Completeness_Config__mdt`) where admins list which fields are "required for completeness" per object
- Same metadata feeds the formula in Tier 1 — single source of truth

This is the design you described. ~2 sessions to build cleanly. Requires Apex (or just LWC + LDS) and component testing.

### Tier 3 — Workflow integration (multi-session)

- All of Tier 2, plus:
- Scheduled Flow that runs daily, finds records still incomplete after N days, auto-creates a Task assigned to the owner: "Intake-00042 has been incomplete for 3 days. Open and finish."
- Dashboard component on Home: "Records awaiting your completion: 7" → click → goes to the filtered list view
- Optional: email digest

**Recommendation:** Build Tier 1 now (we can ship it with the intake/dashboard work). Tier 2 once dashboards are stable and you've seen real advocate use. Tier 3 only if Tier 2 doesn't move the needle.

---

## 9. Test plan for "every field has something in it"

Since you offered to run one comprehensive test, the right test is **two** runs:

**Test A — Maximally complete full intake:**
- Pick every safety_status / urgency / contact_safety value
- abuser_nearby = "no" (to test the path where Risk_Level does NOT auto-tier to High)
- weapons_in_home = "no"
- Fill every Step 2 field including pronouns, relationship_to_abuser, still_living_together
- adults=2, children=1, child_ages="5"
- Check 3 of `urgent_need[]`, 5 of `needs[]`
- referred="Friend or family member" (a value that DOES map to a SF picklist)
- Write a story
- Submit

**Expected:** every structured field populates, Risk_Level = "Unknown" (not High), Referral_Source = "Friend or Family"

**Test B — Minimally complete full intake:**
- Just first_name, email, safety_status, urgency, contact_safety, consent
- Everything else blank

**Expected:** record creates, advocate sees ALL THE BLANK FIELDS, completeness flag (once we build Tier 1) shows long list of warnings

These two tests bracket the realistic range and validate the system handles both extremes gracefully.

---

## Next-session shortlist (in priority order)

1. **Kill standard-home from both apps** — 5 minutes, removes the dual-home noise
2. **Run Test A + Test B** — confirm every mapping works at both extremes
3. **Build Tier 1 completeness fields** on Intake and Hotline_Call — incremental value, low complexity
4. **Reports + dashboards** — the existing in-flight work, now scoped for prod-direct build
5. **Set up one ActionPlanTemplateGroup** as a proof-of-value, see if Lana would actually use it
6. **Decide on pmdm — use lightly or skip**

We can stop after #3 and have a meaningfully better experience for Lana on day 1. Everything below #3 is "make it better" rather than "make it work."
