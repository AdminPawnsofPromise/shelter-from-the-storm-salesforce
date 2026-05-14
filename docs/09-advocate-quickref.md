# Advocate Quick Reference — SFTS Salesforce

A one-page guide for staff answering the phone, handling intakes, and tracking services. Written for someone who has never used Salesforce before.

## Logging in

Go to **https://shelterfromthestorminc.lightning.force.com/** (or use the "Salesforce" bookmark on your work computer).

Sign in with your `@sftsinc.com` username and password. If MFA prompts you for a code, follow the prompts.

If you forget your password, click "Forgot Your Password?" on the login screen — it goes to the email address on your user record.

## Finding the SFTS Operations app

Top-left corner — click the **9-dot grid icon** (App Launcher). Type "**SFTS**" in the search. Click **SFTS Operations**.

This is your daily home. The navigation menu at the top has:
- **Home** — your dashboard and tasks
- **Hotline Calls** — every call logged from the 24/7 line or the website form
- **Contacts** — survivors, with their full record
- **Shelter Stays** — who's currently in shelter
- **Danger Assessments** — Campbell DA-20 records
- **Mandatory Reports** — APS, DCS, and law enforcement reports filed
- **Cases** — Service Cloud case records
- **Programs** & **Service Deliveries** — for grant reporting

## Most common daily tasks

### Take a call (hotline or otherwise)

**Easy way:** click the **"+" icon top-right of any page → Log Hotline Call.** A 2-screen guided form opens. Fill it out as you talk to the caller. When you finish and click "Next" on the second screen, a record is created automatically.

**Field-by-field:**
- **Caller Type:** who's calling? Survivor / Concerned Person (friend/family) / Professional (police, hospital, etc.) / Hangup (caller disconnected) / Other
- **Caller Anonymous:** check this if they wouldn't give a name. Caller Name field can stay empty.
- **Caller Name:** their first name only is fine. Even a name they only use here.
- **Caller Phone:** what they called from or what they gave you.
- **Phone Safe to Return:** **CHECK ONLY IF** the caller confirmed it's safe to call back. Default is UNCHECKED for a reason — many DV callers can't have us call back without endangering them.
- **Caller County:** which Indiana county? Auto-flags "In Service Area" if it's Marion, Shelby, Johnson, or Hancock.
- **Call Type:** Crisis / Information Only / Referral / Shelter Inquiry / Other
- **Primary Issue:** Domestic Violence / Sexual Assault / Stalking / Human Trafficking / Teen Dating Violence / Other
- **Imminent Danger Indicated:** check if the caller mentioned anything suggesting immediate physical danger.
- **Outcome:** what you did or what happened. Required to save.
- **Outcome Notes:** what they said and what you said. Keep this professional — it can be subpoenaed.
- **Mandatory Report Triggered:** check if this call requires APS, DCS, or law enforcement report. **If checked, you must file the report separately within statutory time limits** AND create a Mandatory_Report__c record.

### See who called the website intake form

If your site is wired up to Salesforce (after Day 5 integration setup), every form submission becomes a Hotline_Call__c automatically — usually within 2-3 seconds of the survivor clicking Send.

**Find them:**
- **Hotline Calls** tab → **Today's Calls** list view (top of list view dropdown)
- Or App Launcher → search "Today's Calls"

Each website submission has Caller Type = Survivor, Outcome = Information Provided by default. You update Outcome after you've called them back.

**Critical safety signals in the notes:** the website form now captures whether the abuser is nearby and whether weapons are in the home. These appear in the **Outcome Notes** field with `** ABUSER NEARBY **` and `** WEAPONS in home **` tags. Read these FIRST before calling back.

### Admit a survivor to shelter

From the Contact's record:
- **New → Shelter Stay** (or use the related list)
- Set Check_In Date/Time to NOW
- Status: Active
- Number of Adults: 1 (including her)
- Number of Children: how many came with her
- Pets: dog / cat / none / other (don't turn away because of pets — we work with that)
- Save

While she's in shelter, the stay shows up in the **"Currently In Shelter"** list view.

When she exits:
- Open the Shelter Stay record
- Status → Exited (or Transferred or No Show)
- Check_Out Date/Time
- **Exit Destination** (required — for VOCA reporting: Own Apartment, Family, Friends, Transitional Housing, Hotel, Other Shelter, Returned to Abuser, Homeless, Hospital, Unknown, Other)
- Exit Reason (Goals Met / Rules Violation / Max Stay / Voluntary / Medical / Other)
- Save

### Run a Danger Assessment

If your survivor consents to a Campbell DA-20 assessment:
- From her Contact record: **New → Danger Assessment**
- The 20 questions are pre-filled with the Campbell wording (gender-neutral labels; original Campbell language in field tooltips)
- Each question: **Yes / No / Unknown / Declined to Answer**
- Save
- The **Total Score** and **Danger Tier** (Variable / Increased / Severe / Extreme) auto-calculate
- Severe (14-17) and Extreme (18+) tiers indicate elevated lethality risk — proceed with extra-careful safety planning

### File a mandatory report

If you've made a report to APS, DCS, or law enforcement:
- From the related Hotline Call → check the "Mandatory Report Triggered" checkbox
  - This automatically posts a Chatter alert to the call record so supervisors see it
- Then create a Mandatory Report record:
  - App Launcher → **Mandatory Reports** → **New**
  - Report Type: APS / DCS / Law Enforcement / Other
  - Report Date/Time: when you made the report
  - About Contact: the survivor (or the child — whoever the report is about)
  - Reporting Agency Name, Contact Person, Phone
  - Method: how you reported (phone / online / fax / etc.)
  - Triggering Event: what made you report
  - Narrative: what you reported
  - Outcome Status: starts as "Awaiting Response"; update as you hear back

### Log a service delivery (for VOCA reporting)

After every billable interaction with a survivor — counseling session, court accompaniment, group session, bed night, etc:
- Open the survivor's Contact record
- Click **"Log Service Delivery"** action (in the highlight panel at top, or the dropdown)
- Pick the Service (Court Accompaniment, Hotline Crisis Call, Shelter Bed Night, etc.)
- Date defaults to today
- Quantity: usually 1 (but for a 60-minute session you might enter 60 if billing in minutes)
- Attendance Status: Present / Absent / etc.
- Save

This is the data that feeds your VOCA and FVPSA reports.

## Safety reminders

- **NEVER** type a survivor's address into notes if she has Indiana ACP enrollment
- **NEVER** call a number unless "Phone Safe to Return" is checked
- **NEVER** identify yourself as SFTS in voicemail unless the caller said it's OK
- **ALWAYS** lock your computer when you step away

## Find help

If something looks wrong or you don't know what to do:
- **Daniel:** director@sftsinc.com (CTO + acting admin)
- For technical issues: the Salesforce Setup → Setup Audit Trail shows what changed recently

## Common keyboard shortcuts (Salesforce)

- `Ctrl + /` — focus search bar
- `Ctrl + Shift + L` — log out
- Type `?` on any page — Salesforce shortcuts help
- Click your photo top-right → "Switch Account" if you have multiple accounts

## "I'm overwhelmed"

That's OK. There's a lot here. **The two screens you'll use 90% of the time are: the SFTS Operations app and the Hotline Call form (via the "+" → Log Hotline Call action).** Everything else is for slower, less-frequent tasks. Start there. Daniel will help you with the rest.
