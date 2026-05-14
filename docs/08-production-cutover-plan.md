# Production Cutover Plan — sfts-prod-DANGER

**Status:** Draft, to be reviewed by Daniel before execution.
**Estimated total time:** 90 minutes (deploy: 10 min, manual setup: 30 min, validation: 20 min, training: 30 min).

This is the plan to promote everything we've built in sandbox to your production org. Before this happens, the build is functionally complete but **only Daniel can use it in sandbox**. After this, Brittany / Lana / future advocates can use it in production.

## When to do this

**After:**
- ✅ Daniel completes the Netlify integration setup in sandbox (`docs/06-netlify-integration-setup.md`)
- ✅ Daniel does a UAT pass in sandbox and confirms the system feels right
- ✅ Any UAT-driven polish items are landed

**Not before** the above, because every sandbox change after cutover is a deltas-to-promote problem.

## What gets promoted

Everything in `force-app/main/default/`:

| Category | Count | Notes |
|---|---|---|
| Custom objects | 4 (Hotline_Call, Shelter_Stay, Mandatory_Report, Danger_Assessment) | + 1 custom field on caseman__Intake__c |
| Custom fields on standard objects | 11 on Contact | VOCA demographics, ACP, county |
| Global picklist | 1 (Indiana_County) | 92 counties + Out of State + Unknown |
| Lightning App | 1 (SFTS Operations) | |
| List views | 8 | Across the 4 custom objects |
| Compact layouts | 4 | One per custom object |
| Page layouts | 5 | Hotline_Call, Shelter_Stay, Mandatory_Report, Danger_Assessment, Contact (no changes to Contact layout) |
| Tabs | 4 | One per custom object |
| Permission sets | 2 (SFTS_Build_All_Access, SFTS_Advocate) | |
| Sharing rules | 4 | All-internal R/W on the 4 custom objects |
| Flows | 5 | Hotline Intake screen flow + 2 auto-default flows + 2 Chatter alert flows |
| Quick actions | 2 (Log Hotline Call, Log Service Delivery) | |
| Validation rules | 8+ | Across multiple objects |
| Report folder | 1 (SFTS Operations) | Reports themselves are built in UI |
| Installed packages metadata | 5 | Already match prod — informational only |

## What does NOT get promoted

- **Test data** (the 5 synthetic Contacts, 18 hotline calls, etc.). These are sandbox-only.
- **Daniel's UAT records** (any test records he created via UI in sandbox).
- **The Connected App.** It's created via Setup UI per the Day 5 doc, not deployed as metadata.
- **PMM Programs + Services** as DATA. Programs and Services are records, not metadata. They need to be re-seeded in prod via the `scripts/seed-test-data.ps1`-style approach but **with the real program list** (no synthetic data).

## Pre-flight check (do this first)

```powershell
# Confirm the prod alias is still authenticated
sf org list

# Look at the prod org to see what's already there
# (We did this in Day 1 — check for any drift since)
sf data query --target-org sfts-prod-DANGER --use-tooling-api --query "SELECT QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName IN ('Hotline_Call__c','Shelter_Stay__c','Mandatory_Report__c','Danger_Assessment__c')"
# Expected: 0 records. If any of these already exist in prod, STOP and investigate.

# Validate the deploy WITHOUT actually deploying
sf project deploy validate --source-dir force-app --target-org sfts-prod-DANGER --wait 30
# Expected: 0 errors. If errors, fix them before proceeding.
```

If validation succeeds, you'll get a deploy ID. The cutover deploy can then be done as a "quick deploy" referencing that validation ID, which is faster than a full deploy.

## The deploy

```powershell
# Real deploy. ~5-10 minutes.
sf project deploy start --source-dir force-app --target-org sfts-prod-DANGER --wait 30
```

What happens during this:
- Salesforce parses every metadata file
- Applies in dependency order (objects → fields → layouts → permsets → flows)
- Activates new sharing rules (these queue an async recalculation that may take minutes; ok to proceed)
- Reports any errors

**If the deploy fails:** nothing changes in prod. Salesforce deploys are atomic for source format. Fix the errors and re-run.

## After the deploy

### 1. Seed Programs and Services in production

The seeded PMM Programs and Services in sandbox are real configuration — same set of programs/services in prod. Re-run the relevant portion of the seed script targeting prod:

```powershell
# Temporarily flip default to prod for this command only
sf data create record --target-org sfts-prod-DANGER --sobject pmdm__Program__c --values "Name='24/7 Hotline' pmdm__Status__c=Active pmdm__Description__c='24-hour crisis hotline serving Central Indiana survivors'"
# ... repeat for the 4 other programs
# ... then seed the 20 services bound to those programs
```

This part of `scripts/seed-test-data.ps1` can be cherry-picked — just don't run the synthetic Contact / Hotline_Call / Shelter_Stay / etc. portions.

### 2. Create the Connected App in production

Walk through `docs/06-netlify-integration-setup.md` Phase 2 against production this time. Use the SAME keypair you generated for sandbox (or generate a new one and update Netlify env vars).

### 3. Update Netlify env vars

When pointing the Netlify Function at prod, change:
- `SF_LOGIN_URL` from `https://test.salesforce.com` (sandbox) to `https://login.salesforce.com` (prod)
- `SF_USERNAME` from `admin@sftsinc.com.dev` to `admin@sftsinc.com`
- `SF_CONSUMER_KEY` to the prod Connected App's Consumer Key
- `SF_PRIVATE_KEY` if you regenerated the keypair

### 4. Assign permission sets to real users

```powershell
# Daniel (admin) gets the build admin permset
sf org assign permset --target-org sfts-prod-DANGER --name SFTS_Build_All_Access --on-behalf-of admin@sftsinc.com

# When Lana is ready, give her the advocate permset
sf org assign permset --target-org sfts-prod-DANGER --name SFTS_Advocate --on-behalf-of director@sftsinc.com

# When Brittany returns to the role, give her advocate perms
# sf org assign permset --target-org sfts-prod-DANGER --name SFTS_Advocate --on-behalf-of clientadvocate@sftsinc.com
```

### 5. Smoke test in production

```powershell
# Create a synthetic Hotline Call in PROD (delete after testing)
sf data create record --target-org sfts-prod-DANGER --sobject Hotline_Call__c --values "Call_Start_DateTime__c=2026-05-15T15:00:00Z Caller_Type__c=Survivor Call_Type__c=Crisis Primary_Issue__c='Domestic Violence' Outcome__c='Information Provided' Outcome_Notes__c='PROD SMOKE TEST - delete me'"

# Verify it landed
sf data query --target-org sfts-prod-DANGER --query "SELECT Name, Outcome__c FROM Hotline_Call__c WHERE Outcome_Notes__c LIKE 'PROD SMOKE TEST%' LIMIT 1"

# Delete the smoke test record
# (use the Id returned from the query above)
sf data delete record --target-org sfts-prod-DANGER --sobject Hotline_Call__c --record-id <Id from above>
```

Also test the Netlify integration end-to-end:
- Submit a real form on the live website (with synthetic data)
- Verify it lands in prod Salesforce
- Delete the test record

### 6. Training

Schedule 30 minutes with Lana to walk her through:
- Logging into Salesforce production (her existing director@sftsinc.com creds)
- The SFTS Operations app in the App Launcher
- How to take a hotline call (Log Hotline Call quick action or use the screen flow)
- How to view her caseload via list views
- How to log a service delivery against a Contact

See `docs/09-advocate-quickref.md` (if it exists by the time we cut over).

### 7. Daniel goes live

After the smoke test passes, the system is "live" in prod. Daniel and Lana use it for one week to surface anything missing.

Brittany can be reactivated as a user whenever appropriate.

## Risk register

| Risk | Likelihood | Mitigation |
|---|---|---|
| Deploy fails mid-way | Low | Source-format deploys are atomic. Fail = no changes. |
| Sharing rule recalculation takes hours | Low | Async, queued. Won't block work. |
| User finds a bug in UAT after cutover | Medium | Fix forward — deploy patches as needed. |
| Connected App misconfigured in prod | Medium | Test integration with synthetic data before going live. |
| Lana doesn't log in for a week | Medium | Schedule a training session to ensure first login happens. |
| Existing 1 caseman__Intake__c record breaks | Low | New custom field defaults to null — no migration impact. |
| Permset can't be assigned (license issue) | Low | SFTS has 11 Salesforce licenses, 3 used. Plenty of room. |

## Rollback

If cutover succeeds but something's badly wrong:

1. **Bug in a flow:** deactivate the flow via Setup UI. The system continues to work without that automation. Fix and re-deploy.
2. **Bug in a validation rule:** deactivate the rule (it has an `<active>` element — set to false and redeploy).
3. **Catastrophic problem with a custom object:** can't easily delete deployed metadata. Use a destructive changes deploy. Better: fix forward.
4. **Connected App issue:** disable the Connected App. The website form continues to capture submissions in Netlify; just no auto-create in Salesforce until fixed.

Salesforce takes nightly backups of all production data. No data migration happens during cutover, only metadata changes.

## Sign-off checklist

Before pulling the trigger:
- [ ] Sandbox UAT complete and Daniel signed off
- [ ] All polish items from UAT committed and re-deployed to sandbox
- [ ] Sandbox-side Netlify integration verified end-to-end
- [ ] Daniel has 90 minutes blocked on calendar
- [ ] Validation deploy succeeds against prod (Pre-flight check above)
- [ ] Daniel has the JWT private key for the new prod Connected App
- [ ] Lana available for 30-min training within 48 hours
