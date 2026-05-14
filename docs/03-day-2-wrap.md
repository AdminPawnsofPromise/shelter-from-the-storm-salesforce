# Day 2 Wrap — 2026-05-14 (well past midnight)

## What got done

### Sandbox set up and active
- `sfts-dev` (org ID `00DWr00000BgbeLMAR`) authorized to CLI
- Default target org flipped from `sfts-prod-DANGER` to `sfts-dev`
- **All work the rest of the day happened in sandbox**
- Sandbox timezone fixed to Indiana Eastern (parity with prod)

### Baseline metadata captured
- 181 files from `Contact`, `Account`, `Case`, plus System Administrator profile
- Confirmed managed-package field availability (caseman + pmdm fields exist on Contact/Case/Account; we don't need to duplicate)
- Confirmed Contact OWD is already `Private` (no work needed)

### Three custom objects built, deployed, verified
| Object | Fields | Layout sections | Tab | Validation rules |
|---|---|---|---|---|
| `Hotline_Call__c` | 19 | 5 | Phone icon | Outcome required to end call |
| `Shelter_Stay__c` | 12 | 4 | Home icon | Exit destination required when Exited |
| `Mandatory_Report__c` | 17 | 5 | Notebook icon | Reporter required |

### Global picklist
- `Indiana_County` value set: all 92 Indiana counties + Out of State + Unknown
- Used by `Hotline_Call__c.Caller_County__c` and `Contact.Indiana_County_of_Residence__c`

### Contact custom fields (10)
- `VOCA_Race__c` (MultiselectPicklist) — federal-compliant categories
- `VOCA_Ethnicity__c`, `VOCA_Sexual_Orientation__c`, `VOCA_Disability__c`, `VOCA_LEP__c`
- `Primary_Language__c` (text 50)
- `Veteran_Status__c`
- `Indiana_ACP_Enrolled__c` (checkbox), `Indiana_ACP_Effective_Date__c`
- `Indiana_County_of_Residence__c` (uses Indiana_County global picklist)

### Permission set
- `SFTS_Build_All_Access` deployed and assigned to admin user
- Grants object access + FLS + tab visibility on all new objects/fields
- Pattern documented for adding new fields going forward

### Architectural decisions (ADRs)
- ADR-007: Hotline calls allow anonymous (no Contact required)
- ADR-008: Campbell DA-20 as the danger assessment instrument
- ADR-009: Shelter beds tracked as stays (not named beds)
- ADR-010: Mandatory reports are audit-only (no approval workflow)
- ADR-011: Service area = Marion, Shelby, Johnson, Hancock counties
- ADR-012: Website intake forms integrate via Netlify Function → Salesforce REST API (deferred to Day 5)
- ADR-013: Contact OWD already Private (no change needed)

## Gotchas hit (and lessons captured for the rest of the build)

1. **FLS defaults closed.** Custom fields aren't visible to anyone until a profile or permset grants FLS. Even System Administrator must be granted explicitly. Solution: maintain `SFTS_Build_All_Access` permset and assign to anyone needing access.
2. **Required fields can't have FLS entries.** Salesforce implicitly grants access to required fields. Don't add `<fieldPermissions>` for them.
3. **User lookups can't have Restrict/Cascade delete or default values.** Workaround: optional field + validation rule + Day 3 record-triggered flow to default to current user.
4. **Layouts live at top-level `force-app/main/default/layouts/`, NOT nested under objects.** Hotline's worked initially by accident.
5. **PermissionSet XML element ordering matters.** All `<objectPermissions>` blocks must be contiguous, same for `<fieldPermissions>` and `<tabSettings>`.
6. **Contact-level history tracking is off by default.** Either enable at object level OR set `trackHistory=false` on individual fields. Day 3 polish: enable for VAWA audit compliance.
7. **Standard object metadata changes are risky to deploy.** We didn't need to touch Contact.object-meta.xml because OWD was already Private. Saved a potential snag.

## Test coverage in sandbox
- Created `HC-00002` synthetic test Hotline_Call__c record (Daniel via UI)
- Created/deleted `HC-00000`, `ST-00000`, and a synthetic Jane Test Contact via CLI
- Verified all 19 Hotline_Call__c fields populate correctly
- Verified Shelter_Stay__c length-of-stay formula computes correctly (3 days from check-in 5/10 → today 5/14)

## Git state at end of Day 2

```
$ git log --oneline
[14 commits — see git history]
```

All on `main`. Working tree clean.

## What's NOT done yet — Day 3 plan

### Polish on Day 2 objects
1. **Record-triggered Flow on `Mandatory_Report__c`**: auto-populate `Reporter__c = $User.Id` on create. Currently advocate must manually pick themselves.
2. **Formula field `Auto_In_Service_Area__c`** on both `Hotline_Call__c` and `Contact`: TRUE when County is in (Marion, Shelby, Johnson, Hancock). Currently `In_Service_Area__c` is a manual checkbox.
3. **Contact history tracking**: enable at object level, then turn on `trackHistory=true` for `Indiana_ACP_Enrolled__c`, `Indiana_ACP_Effective_Date__c`, and the other PII fields. Required for VAWA audit defensibility.
4. **CompactLayout** on each object: shows in record highlights panel header. Currently using system defaults.

### Day 3-4 net new
5. **Danger_Assessment__c** custom object encoding Campbell DA-20 (20 yes/no questions, 4 tier formula). Decide: custom object vs. extending `caseman__Assessment__c`.
6. **Hotline Intake screen flow** (per original brief Day 4): multi-screen wizard that creates Hotline_Call__c + optional Contact + optional Intake.
7. **Compact dashboards**: bed availability count, hotline volume, intake pipeline.

### Day 5 net new (per ADR-012)
8. **Netlify Function for website form integration**: receive Netlify webhook → authenticate to Salesforce → create records.
9. **Connected App + JWT auth flow** for the integration.

## What you need to do before Day 3

Nothing required. Sleep. The sandbox state is committed. The org alias `sfts-dev` is the default — every command tomorrow lands in sandbox unless you explicitly target prod.

When you come back, just say "Day 3" and we tackle the polish list. Or if something feels wrong in the UI overnight, screenshot it and ping me.

## Resume command for fresh terminal

If you close everything and need to come back fresh:

```powershell
sf org list                           # verify sfts-dev still default
sf org open --target-org sfts-dev     # open sandbox in browser
git log --oneline                     # see what got done
```
