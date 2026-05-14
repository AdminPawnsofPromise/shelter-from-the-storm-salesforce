# Integration Setup — RESOLVED

**Status:** ✅ End-to-end working as of Day 7, 12:27 PM (2026-05-14).

## Final state

| Component | Status |
|---|---|
| JWT keypair | ✅ `secrets/sfts-website-private.key` + `secrets/sfts-website-public.crt`, valid 5/14/2026 → 5/11/2036 |
| Salesforce app | ✅ Classic Connected App `SFTS Website Integration v2` (ID `0H4Wr0000003Dn7KAE`), deployed via metadata XML — NOT the original External Client App |
| Pre-authorization | ✅ System Administrator profile assigned |
| Netlify env vars | ✅ `SF_CONSUMER_KEY`, `SF_USERNAME=admin@sftsinc.com.dev`, `SF_LOGIN_URL=https://test.salesforce.com`, `SF_PRIVATE_KEY` |
| Webhooks | ✅ quick-intake → `/.netlify/functions/salesforce-intake`, intake → same function (both re-enabled after auto-disable) |
| Function | ✅ Diagnostic logging removed; production-clean |
| End-to-end test | ✅ HC-00020 created from quick-intake submission |

## Why the original setup failed

The original snapshot ([6-netlify-integration-setup.md](06-netlify-integration-setup.md)) directed creating
an **External Client App** because Salesforce retired the UI for creating
classic Connected Apps in 2024. We followed that path and hit
`{"error":"app_not_found","error_description":"External client app is not installed in this org"}`
from the JWT bearer endpoint, despite the app showing as **Enabled** /
**Local** / **JWT Bearer Flow enabled** with the cert uploaded and the
"Admin approved users are pre-authorized" policy applied.

**Root cause:** External Client Apps don't reliably register in the
Connected App OAuth registry that the JWT bearer endpoint queries —
they're a separate registry with a missing/non-obvious activation step
for JWT bearer flow. The UI gives no indication that this step is
needed, and the resulting `app_not_found` error is misleading (the app
IS in the org; it's just not in the registry the JWT endpoint uses).

## What fixed it

Salesforce retired the *UI* for creating classic Connected Apps but the
platform still fully supports them via metadata deploy. Path B from the
debug session:

1. Authored [force-app/main/default/connectedApps/SFTS_Website_Integration_v2.connectedApp-meta.xml](../force-app/main/default/connectedApps/SFTS_Website_Integration_v2.connectedApp-meta.xml)
   — minimal Connected App XML with `<isAdminApproved>true</isAdminApproved>`, the public cert inline as base64, and `api` + `refresh_token` scopes.
2. Deployed via `sf project deploy start --source-dir force-app/main/default/connectedApps/... --target-org sfts-dev`. Took 1.3s.
3. In Salesforce sandbox UI (via direct record-ID URL `/0H4Wr0000003Dn7KAE`):
   - Verified `Permitted Users = Admin approved users are pre-authorized` (set by metadata).
   - Manage Profiles → checked System Administrator → Save. **This step is not deployable via the ConnectedApp metadata type and must be done in the UI** (or via a separate Profile metadata deploy targeting the connectedAppAccess block).
4. Manage Consumer Details → copied new Consumer Key → pasted into Netlify `SF_CONSUMER_KEY` env var → triggered Netlify redeploy.
5. Test submission of quick-intake form → `Created Hotline_Call: a0cWr000004ZyGjIAK` in the function log → record verified in sandbox via SOQL.

## Other debug findings (sidequests we ruled out)

- **Consumer Key transcription error (red herring).** The earlier snapshot doc recorded the key with three lowercase `l`s where Salesforce actually had 1 lowercase `l` + 2 uppercase `I`s. This wasted ~30 min chasing a non-issue. **Always source the Consumer Key from the Salesforce UI's Copy button at debug-time, not from previously-recorded docs.**
- **Audience claim (`aud`)**: The function uses `SF_LOGIN_URL` for both the token endpoint AND the JWT `aud` claim. Both `https://test.salesforce.com` and `https://shelterfromthestorminc--dev.sandbox.my.salesforce.com` (My Domain) work for sandbox once the Connected App is properly registered. Currently set to `https://test.salesforce.com` (canonical sandbox audience).
- **Netlify auto-disabled the webhook** after 6 consecutive 4xx responses from the function during debugging. Symptom: form submissions show up in "Verified submissions" but function log is empty. Fix: edit the disabled hook in Form notifications → Save (no value change needed) → it re-enables.

## Intake-form end-to-end test (done same session)

After quick-intake passed, we tested the 5-step `intake` form and surfaced
five mapping issues. All fixed in `sfts-site/netlify/functions/salesforce-intake.js`:

1. **Pronouns field unusable via REST.** `Contact.Pronouns` exists in the
   schema but Salesforce returns `INVALID_FIELD` until the org enables
   "Gender Identity and Pronouns Fields" in Setup → User Interface.
   Workaround: omit `Pronouns` from the Contact payload; the value still
   flows into `Website_Submission_Notes__c`. To restore the structured
   field later, enable the Setup toggle and re-add the mapping.
2. **`caseman__AgeCategory__c` picklist mismatch.** The caseman package
   ships a 4-value picklist (Child / Youth / Adult / Senior), not the
   granular age ranges the website form uses ("Under 18", "18-24",
   "25-34", ...). Rewrote `mapAgeRange()` with an explicit lookup; also
   normalizes en-dash (`–`, U+2013) to a regular hyphen so the form's
   "18–24" value matches the lookup key.
3. **`caseman__PreferredCommunicationMethod__c` value mismatch.** The
   picklist values are `Call` / `Text` / `Email` — function was sending
   `Phone`. Now sends `Call`.
4. **`Risk_Level__c` required on caseman__Intake__c.** Added
   `deriveRiskLevel()` that returns `High` when the survivor flagged
   `abuser_nearby=Yes` or `weapons_in_home=Yes` (VAWA lethality
   indicators), else `Unknown`. Lets the advocate prioritize the
   callback based on a self-reported safety signal while not
   over-claiming for cases that need advocate assessment.
5. **Standard Contact duplicate rule blocks returning survivors.** Added
   `findOrCreateContact()` which catches `DUPLICATES_DETECTED` from the
   REST create response, extracts the matched Contact Id from the error
   body (Salesforce returns it as part of `matchRecords`), and links the
   new Intake to that existing record. New survivors still get a fresh
   Contact created. Either path captures the latest survivor-provided
   data in `Website_Submission_Notes__c` on the Intake — Contact
   record itself is never overwritten by website submissions.

End-to-end verified: Contact `003Wr00001BMbJpIAL` (matched via dedup) +
Intake `a0bWr000005TwP7IAK` with `Risk_Level__c=Unknown` and the full
5-step form captured in notes.

## Open follow-ups (none blocking)

- Rotate the v2 Connected App Consumer Secret (was exposed in chat during debug). Manage Consumer Details → Generate Staged → Apply. JWT bearer flow doesn't use the secret, so this is hygiene only.
- Production cutover (per [08-production-cutover-plan.md](08-production-cutover-plan.md)) needs the same metadata deploy + env-var setup in prod, with `SF_LOGIN_URL=https://login.salesforce.com` and a prod-issued Consumer Key.
- Optional: enable Salesforce "Gender Identity and Pronouns Fields" in Setup if structured pronouns capture is wanted (currently in notes only).
