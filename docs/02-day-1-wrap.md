# Day 1 Wrap — 2026-05-14

## What got done

### Project foundation
- SFDX project initialized at `C:\Users\tzadi\Documents\CLAUDE\SFTS\SalesForce`
- Git repo on `main`, 4 commits
- `.gitignore` safety-tuned to block real-data folders and credentials
- `README.md`, `.forceignore`, `manifest/package.xml`, `config/sandbox-dev.json` all in place
- `docs/00-decisions.md` (ADR log) — 6 ADRs accepted
- `docs/01-org-discovery.md` — full audit of org state
- `force-app/main/default/installedPackages/` — 5 InstalledPackage metadata files captured

### Org understood
- Enterprise Edition, US production pod USA788
- API version 66.0, locked in `sfdx-project.json`
- 5 managed packages installed (caseman, pmdm, OmniStudio, SFDO Base, Sales Insights)
- **Architecture: legacy NPSP-era stack (caseman + pmdm), confirmed via probes**
- 8 active users (3 humans, 5 system); 11 Salesforce licenses with 3 used
- Zero org-local custom objects (clean slate for new builds)

### Production changes executed and audited
- ✅ Org timezone changed: Pacific → `America/Indiana/Indianapolis`
- ✅ Brittany Stephens' 4 `caseman` permission sets removed (audit IDs in `01-org-discovery.md`)
- ✅ Nonprofit Cloud Case Management RUL: revoked from Brittany, granted to admin
- ✅ `caseman__ManageCases` permission set assigned to admin

### Sandbox
- Definition file written: `config/sandbox-dev.json`
- Creation submitted async — job ID **`0GRWj0000001XQ9OAM`**, alias `sfts-dev`
- Status at end of Day 1: **Processing, 75%** (the final 25% sometimes takes longer than the first 75%; Salesforce will email when done)
- **NOT YET AUTHORIZED** to the CLI — Day 2 morning task

## Resume sequence for Day 2 morning

In order, copy-paste these in PowerShell from the project folder:

```powershell
# 1. Check sandbox status (read-only)
sf data query --target-org sfts-prod-DANGER --use-tooling-api --query "SELECT SandboxName, Status, CopyProgress, EndDate FROM SandboxProcess WHERE Id = '0GRWj0000001XQ9OAM'"

# 2. Once Status = "Completed", authorize the sandbox under alias sfts-dev
sf org resume sandbox --job-id 0GRWj0000001XQ9OAM --target-org sfts-prod-DANGER --wait 15

# 3. Flip the default org from DANGER to sandbox (so accidental commands hit dev, not prod)
sf config set target-org=sfts-dev

# 4. Verify it stuck
sf org list

# 5. Open the sandbox in the browser for the first time (sets your password via emailed reset link)
sf org open --target-org sfts-dev
```

Step 5 is important: Salesforce sends an activation email to **`admin@sftsinc.com.dev`** (note the `.dev` suffix). You set a password there. After that, your CLI works against sandbox without needing browser auth again.

Then we run the baseline metadata retrieve (Step 5 of the original plan) and move into Day 2 building.

## Day 2 plan (proposed — finalize at start of Day 2)

### Morning
1. Authorize sandbox + flip default + activate password (above)
2. Baseline retrieve: pull standard objects (`Contact`, `Account`, `Case`) + key managed package layouts, commit as "baseline"
3. Decision check-in: a small number of open design questions (below)

### Afternoon — Custom objects in sandbox
4. Build `Hotline_Call__c` — the priority object
5. Build `Bed_Assignment__c`
6. Build `Mandatory_Report__c`
7. Decide: `Danger_Assessment__c` custom OR extend `caseman__Assessment__c`?

### End of Day 2
8. Custom fields on `Contact` — VOCA demographics, Indiana ACP flag, address-suppression flag, safe-contact protocol, county-of-residence
9. Org-Wide Default on Contact set to **Private** (VAWA compliance baseline)
10. Commit and check-in

## Open questions to think about overnight

These don't need an answer tonight; we'll work through them at Day 2 start. Just food for thought.

1. **Anonymous hotline calls.** Many hotline calls are from callers who never give a name. Should `Hotline_Call__c` allow a call record with NO Contact reference (i.e., `Contact__c` is optional), or do we always create a Contact (even a "Jane Doe / Anonymous Caller #437" placeholder)? Each approach has reporting trade-offs.
2. **Danger Assessment instrument.** Are you using the Campbell Danger Assessment (the 20-item DA), the shorter DA-IT (Danger Assessment for Immigrant Women), the Lethality Assessment Protocol (LAP, 11 items), or something else? The scoring and threshold tiers we encode depend on which instrument.
3. **In-area vs out-of-area counties.** Which Indiana counties are SFTS's primary service area, vs out-of-area referrals? (Affects ICJI reporting categorization.)
4. **Bed board model.** Do you want beds named (e.g., "Bed A1," "Bed A2," ...) as records in a `Bed__c` object, or just a count of available beds? Named beds give richer reporting but more setup; bed-count gives faster build.
5. **Mandatory reporting workflow.** When an advocate flags a mandatory-report situation, do you want a *Salesforce* approval workflow (chatter notification to supervisor, supervisor approves before the report is closed) or just a record kept for audit?

---

## Git state at end of Day 1

```
023c1d4 Day 1 production changes + sandbox definition
ebec3c1 Accept Day 1 ADRs based on Daniel decisions
c8d7ea4 Day 1 org discovery: legacy NPSP-era stack confirmed
4174065 Initial project structure
```

All on `main`, all committed locally. No remote yet (we'll set up GitHub or another remote when convenient — not blocking).

## What you should do before Day 2

Honestly? Nothing required. The sandbox provisions on Salesforce's side regardless of your computer.

**Where the sandbox-ready email will arrive:** The Salesforce CLI authenticated as username `admin@sftsinc.com`, which is YOUR (Daniel's) user. The actual mailbox on that user record at the time of sandbox submission was **`timdstep@gmail.com`** — that's where the "Your sandbox dev is ready" notification will land. (`admin@sftsinc.com` is just a login identifier, not a real mailbox. Common Salesforce gotcha.)

**Late Day 1 follow-up:** Daniel requested admin User.Email be changed from
`timdstep@gmail.com` to `director@sftsinc.com` for future official notifications.
The API update was accepted but the field shows as still pending. Salesforce
sent a confirmation link (probably to both old and new addresses). Until Daniel
clicks the link, future Salesforce emails for admin@sftsinc.com still go to
`timdstep@gmail.com`. This does NOT affect the current sandbox-ready email
(already in flight to timdstep@gmail.com).

When you see that email tomorrow, run the resume sequence above and ping me. If you don't see the email by lunch tomorrow, run the status query in the resume sequence anyway — the email occasionally gets stuck.

Sleep on the 5 open questions if you have time. We can also work through them live tomorrow.
