# Day 5 Wrap — 2026-05-15 (autonomous push, no Daniel interaction needed)

## What got built

### Salesforce repo (committed to this repo)
1. **`Log_Hotline_Call` global Quick Action** — launches the Hotline Intake flow from anywhere. Deployed and live in sandbox. Daniel can add it to publisher layouts (Setup → Quick Actions → Global Actions) to put it in the "+" menu top-right or wherever desired.
2. **`SFTS_Advocate` permission set** — frontline advocate role for onboarding Lana or future hires. Grants:
   - Read/Edit on all 4 custom SFTS objects + Contact PII fields
   - **No delete** on any of them (preserves audit trail)
   - View on Hotline_Call, Shelter_Stay, Mandatory_Report, Danger_Assessment tabs
   - Use SFTS_Build_All_Access for full admin instead
3. **`docs/06-netlify-integration-setup.md`** — the 30-minute click-through to wire the website integration

### sftsinc.com repo (`../sfts-site/`)
The Netlify Function + dependencies are written into your website folder. Files added:
- **`netlify/functions/salesforce-intake.js`** (~150 lines)
  - Receives Netlify Form webhook on form submission
  - Authenticates to Salesforce via JWT bearer flow (no user OAuth required)
  - Maps `quick-intake` form fields → `Hotline_Call__c` record
  - Returns 200 with the created Salesforce record ID
  - `intake` (full 5-step form) is logged but not yet auto-created — v2 work
- **`package.json`** — declares the `jsonwebtoken` dependency
- **`netlify.toml`** — added `[functions]` block pointing at `netlify/functions/`

These files are **not committed to a git repo** because `sfts-site/` is not a git repo locally on your machine. You'll need to push them to your website's deploy pipeline however you normally do (drag-and-drop to Netlify, Netlify CLI, or git if you have a GitHub repo connected to Netlify).

## How the integration works once Daniel completes setup

```
Survivor fills out quick-intake form on sftsinc.com/get-help.html
                ↓
Netlify receives the form submission
                ↓
Netlify sends webhook → salesforce-intake function (your Netlify Function)
                ↓
Function gets a Salesforce access token via JWT bearer flow
                ↓
Function POSTs to Salesforce REST API /sobjects/Hotline_Call__c/
                ↓
Hotline_Call__c record exists in Salesforce within 2-3 seconds
                ↓
(Optional: a Salesforce flow notifies advocate via Chatter/email — Day 6)
```

## What Daniel does next (~30 min, all one-time)

Walk through `docs/06-netlify-integration-setup.md`. It's 4 phases:
1. Generate the JWT keypair (Git Bash, 2 OpenSSL commands)
2. Create the Connected App in Salesforce (clicks in Setup → App Manager)
3. Set 4 environment variables in Netlify (paste & save)
4. Connect the form webhook in Netlify dashboard (3 clicks)

Then submit a test form on your live site and watch the record appear in Salesforce. Roughly 5 minutes after that's working, **the manual intake re-entry problem is solved.** Survivor hits Send → record exists → advocate sees it in the "Today's Calls" list view they already have.

## Git state at end of Day 5

22 commits on `main` (this commit + 21 prior). Working tree clean.

## What's next — Day 6+

A few high-value items remain. Pick whichever feels right next time:

1. **Test the website integration end-to-end** (after Daniel does the setup) and iterate based on what we learn.
2. **Extend the integration** to handle the full 5-step `intake` form too — maps to `caseman__Intake__c` + Contact creation. The v1 code is wired to route by form_name but the handler for "intake" only logs for now.
3. **Reports + Dashboard in the UI** — Daniel's task per `docs/05-day-4-wrap.md`. The data is now there to make them meaningful.
4. **Mandatory-report Chatter notification flow** — when a Hotline_Call has `Mandatory_Report_Triggered = true`, auto-post in Chatter to alert a supervisor.
5. **Sharing rules** — currently every custom object is OWD=Private. Once we have multiple users, advocates will only see their own records unless a sharing rule says otherwise. Likely we want "Advocates can see all SFTS records by their role."
6. **Field-level history audit** — verify the SFTS_Advocate permset doesn't expose PII it shouldn't.
7. **Onboard Lana** — assign her the SFTS_Advocate permset, walk through her access.

No urgency — pick what feels right when you come back.
