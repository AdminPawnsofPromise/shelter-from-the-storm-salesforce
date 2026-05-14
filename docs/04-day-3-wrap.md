# Day 3 Wrap — 2026-05-15

## What got built

### Major new object: Danger_Assessment__c (Campbell DA-20)
- Custom object per ADR-008 (instrument) and a today-ADR (custom over extending caseman__Assessment__c)
- 28 fields total:
  - 6 metadata: Contact (required Lookup, Restrict-delete), Assessment_DateTime, Assessor, Intake, Hotline_Call, Notes
  - 20 question picklist fields (Yes / No / Unknown / Declined; Q15 and Q17 also have N/A)
  - 2 formula fields: Total_Score (counts Yes across Q01-Q20), Danger_Tier (4-tier classification)
- Layout with 5 sections; tab with Heart icon
- Verified end-to-end: 14 Yes answers → Total_Score=14 → "Severe Danger" tier
- Gendered-language choice: labels use "partner" (gender-neutral); original Campbell wording retained in field descriptions for clinical validation reference

### Hotline Intake screen flow (v1)
- 2 input screens + record-create + confirmation
- Auto-stamps Call_Start_DateTime to NOW() and Advocate to $User.Id
- Picklists inherit values from object schema via `ObjectProvided`/`objectFieldReference` pattern
- Took 5 deploy iterations to land — captured the gotchas in this doc

### Polish pass — Day 3 afternoon delegation
- **Contact history tracking enabled** at object level (`enableHistory: true`); `trackHistory: true` set on `Indiana_ACP_Enrolled__c` and `Indiana_ACP_Effective_Date__c` for VAWA audit defensibility
- **Compact layouts** for all 4 custom objects (Hotline_Call, Shelter_Stay, Mandatory_Report, Danger_Assessment) showing 5-6 key fields in the record header
- **Two record-triggered before-save flows**:
  - `Default Reporter on Mandatory Report` — defaults Reporter__c to current user if blank
  - `Default Assessor on Danger Assessment` — defaults Assessor__c to current user if blank
- Verified the Reporter flow with a synthetic MR-00000 record (auto-populated correctly)

## Lessons captured (Flow XML gotchas)

The Hotline Intake flow taught us these — preserved here so we don't relearn:

1. **Boolean screen fields can't be optional.** Salesforce treats unchecked as a valid value and rejects `<isRequired>false</isRequired>` on boolean inputs. Either set `isRequired>true` or omit the element entirely.
2. **Screen field references in element references use just the field name**, not screen-dotted. So `fld_Caller_Anonymous`, NOT `Caller_Information.fld_Caller_Anonymous`.
3. **`assignRecordIdToReference` conflicts with `inputReference`** on record-create elements. Modern pattern: use `storeOutputAutomatically=true` and reference the create element by name in downstream elements.
4. **`flowruntime:radio` is not a real Salesforce extension.** For picklist fields bound to a record variable, use `<fieldType>ObjectProvided</fieldType>` with `<objectFieldReference>varName.FieldApi__c</objectFieldReference>` — values inherit from the schema.
5. **A screen can't have both `allowFinish=false` and `allowBack=false`.** At least one must be true. First screen: allowBack=true is the safe default even though there's nothing to go back to.
6. **CompactLayout files need `<fullName>` as the first element** matching the file basename, otherwise SFDX rejects with "element fullName missing for a child of type CompactLayout".

## Git state at end of Day 3

19 commits on `main`. Working tree clean.

```
[Day 3 commits]
ac1e481 → 1ab745c → d773923 → 9be46a7 → b718b3f → 7a47c71 → 3d9b07f → ...
```

## Day 4 plan (proposed)

### Carry-forward from Day 3
- Daniel's UI test of the Hotline Intake flow + Danger Assessment (sandbox is still open)
- Any field-wording adjustments based on the test drive

### Day 4 new work
1. **Dashboards** (per original Day 11 brief, pulled forward):
   - Bed availability count (current Shelter_Stays with Check_Out_DateTime IS NULL vs. configured capacity)
   - Hotline call volume by day/week
   - Danger Assessment risk tier distribution
   - VOCA service-delivery summary
2. **Test data seeding script** — synthetic records across all 4 objects so dashboards have data to render. Stays in `scripts/` folder, excluded from deploy.
3. **Lightning App** wrapping all the SFTS objects into a single "SFTS Operations" app, with a custom navigation menu. Easier than hunting in App Launcher every time.

### Day 5 net new (per ADR-012)
4. **Netlify Function for website form integration**: receive Netlify webhook → authenticate to Salesforce → create records.
5. **Connected App + JWT auth flow** for the integration.

## What you should do before Day 4

If you haven't yet, **walk through the Hotline Intake flow** in the open sandbox tab:
- Find it via App Launcher → search "flow" → click Hotline Intake
- Or via the direct URL: `/flow/Hotline_Intake`
- Walk through with a synthetic "Jane Test" caller
- Tell me anything that feels off

Also worth a quick test:
- **Create a Mandatory Report** via the UI (Hotline Calls → New) and verify Reporter auto-populates with your name
- **Create a Danger Assessment** record from a Contact and verify Assessor auto-populates

When you come back, just say **"Day 4"** and we tackle dashboards.
