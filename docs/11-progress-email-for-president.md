# Progress Update Email — for President

> A copy-pasteable email Daniel can send to Lana (or any board member / stakeholder) summarizing the Salesforce build to date. Plain English, no jargon. Edit as needed.

---

**To:** Lana Stephens
**From:** Daniel Stephens
**Subject:** Salesforce build — Week 1 progress update

Hi Lana,

Wanted to give you a status on the Salesforce case management system. We're at the end of Week 1 and ahead of plan. Here's where we are.

## What's been built

**A complete case management system for SFTS, ready for staff to use.** Every piece below is built, tested in a safe development environment, and ready to be turned on for the live org when we're ready.

### Hotline & intake
- A guided 2-screen form for any staff member to log a call to the hotline — automatic timestamping, the survivor's caller info, what was discussed, what we did, and whether mandatory reporting was needed. Validation makes sure no call closes without an outcome.
- An "alert" automatically posts to the call record any time mandatory reporting is triggered, so supervisors see it immediately.

### Survivor records (Contacts)
- Every demographic field VOCA / VAWA / FVPSA grants need: race, ethnicity, sexual orientation, disability, language access, veteran status.
- An Indiana Address Confidentiality Program (ACP) flag and effective-date field, with a rule that requires the date if the box is checked.
- Indiana county field tied to a full list of all 92 counties. A second auto-computed field flags whether the survivor is in our service area (Marion / Shelby / Johnson / Hancock).
- Change history is tracked on the sensitive fields for audit defense.

### Shelter operations
- A "shelter stay" record for every survivor who comes through, with check-in/check-out times, household composition (adults / children / pets), exit destination, and exit reason.
- A "Currently In Shelter" list view so you can see at a glance who's here right now.
- A rule that prevents marking a stay "Exited" without recording where the survivor went — required for VOCA reporting.

### Danger Assessment
- The full Campbell DA-20 instrument built in, with all 20 questions, the scoring formula, and the 4 risk tiers (Variable / Increased / Severe / Extreme). Advocates can complete one with a survivor and the risk score auto-calculates as they answer.

### Mandatory reporting
- Audit log records for every APS, DCS, or law enforcement report filed. Captures what was reported, to whom, when, by whom, the agency case number, and the agency's response.
- Field history tracked on key fields for legal defensibility.
- A rule preventing reports from being closed without documenting the outcome.

### Service tracking (for VOCA reporting)
- All 5 SFTS programs (24/7 Hotline, Emergency Shelter, Court Advocacy, Children's, Outreach) set up.
- 20 specific service types defined across those programs (Shelter Bed Night, Crisis Counseling, Court Accompaniment, etc.).
- A one-click button on any survivor's record to log a service delivery — the building block for every grant report we'll ever submit.

### User access
- Two permission levels defined: full admin (for me) and advocate (for you and any future hires).
- Sharing rules so advocates can see each other's records — necessary for shift changes and supervisor oversight. Contact records remain private at the platform level for VAWA compliance.

### Website integration (95% done)
- The intake form on sftsinc.com has been redesigned with critical safety questions (is the abuser nearby? are there weapons in the home? relationship to abuser? urgent need?). These are designed so staff have a safety picture before they call the survivor back.
- A "smart connector" between the website and Salesforce: when a survivor submits the form, a record is automatically created in Salesforce within 3 seconds. **This piece is wired up but hitting one error we'll fix in the next session — last 5% of the integration.**

## Where we are vs. the plan

The original plan was 2 weeks. We're at the end of Day 7 and have built everything the plan called for plus a few unplanned wins (the website integration was a Day 5 ask that's mostly working already).

Day 8 onwards:
- Finish the website integration debug (~1 hour)
- Walk through everything together in the development environment (Daniel + you) so you can flag anything that looks wrong (~1 hour)
- Promote the entire system to the live Salesforce org you'll use day-to-day (~90 minutes — a careful, well-documented procedure)
- Get you trained on it (~30 minutes — a one-page guide is already written)
- Soft launch with you and (optionally) Brittany if appropriate

## How safe is this

- Every piece of work has been done in a separate sandbox copy of Salesforce, not the live org. **Nothing in our live org has been touched in any way that affects normal use.**
- 27+ separate save points (git commits) capturing each change, so any change can be reviewed or rolled back.
- A documented production-cutover plan is in place for when we go live.
- Synthetic test data only — no real survivor information has ever been entered.

## What I need from you

Nothing urgent. When we're ready to promote to the live org (probably Day 9), I'll want 30 minutes with you to:
1. Walk through the system together
2. Sign off on going live
3. Schedule a 30-minute training session for you to use the system

I'll send a calendar invite when we're ready.

If you have a few minutes earlier, the public-facing change you can see right now is the updated intake form on https://sftsinc.com/get-help.html — we've added a few critical safety questions (especially "is the abuser nearby right now?" and "are there weapons in the home?") that will help staff prepare for safer callbacks.

Let me know if you have any questions or want a deeper walkthrough sooner.

Daniel
