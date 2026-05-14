# Integration Setup — In-Progress Snapshot

**Status as of Day 7 mid-morning:** integration mostly wired, hitting an `app_not_found` error on the JWT auth. Three known fixes to try next session.

## Phases completed

### ✅ Phase 1 — JWT keypair generated
- Files in `C:\Users\tzadi\Documents\CLAUDE\SFTS\secrets\`:
  - `sfts-website-private.key`
  - `sfts-website-public.crt`
- Valid: 5/14/2026 to 5/11/2036

### ✅ Phase 2 — External Client App created in sandbox
- Name: **SFTS Website Integration**
- Type: **External Client App** (not classic Connected App — Salesforce retired that creation UI)
- Cert uploaded: ✅
- OAuth Scopes: `api`, `refresh_token`
- JWT Bearer Flow: enabled
- Permitted Users: "Admin approved users are pre-authorized"
- Authorized profile: System Administrator
- Consumer Key starts with: `3MVG9bYGb9rFSjxSvp8WlwLAKRmrg73C.I0.VbFj2CtKBiBwgZztjzvQhw_dXSWldTj1_c5g7GXl6o9fgSJ8Z`

### ✅ Phase 3 — 4 Netlify env vars set
- `SF_CONSUMER_KEY` = (Salesforce Consumer Key)
- `SF_USERNAME` = `admin@sftsinc.com.dev`
- `SF_LOGIN_URL` = `https://test.salesforce.com`
- `SF_PRIVATE_KEY` = (multi-line PEM as single string with `\n` escapes, "Contains secret values" checked)

### ✅ Phase 4 — Website deployed to Netlify
- Daniel ran `npm install` in `sfts-site` then drag-dropped the folder
- 1 function deployed: `salesforce-intake` at `https://sftsinc.com/.netlify/functions/salesforce-intake`

### ✅ Phase 5 — Webhooks wired in Netlify
- Two HTTP POST notifications configured:
  - quick-intake → /.netlify/functions/salesforce-intake
  - intake → /.netlify/functions/salesforce-intake
- Plus 3 existing email notifications still active

### ⏳ Phase 6 — End-to-end test (FAILED, needs debugging)

**Test performed:** submitted quick-intake form on sftsinc.com with "Webhook test / 3175559999 / morning / Yes leave message / End-to-end webhook test — please ignore"

**Result:**
- ✅ Netlify Forms received the submission
- ✅ Webhook fired, function executed
- ❌ Function failed JWT auth with:
  ```
  Salesforce JWT auth failed (HTTP 400):
  {"error":"app_not_found","error_description":"External client app is not installed in this org"}
  ```
- ❌ No Hotline_Call__c record created in sandbox

## Three fixes to try next session, in order

### Fix #1 — Re-verify Consumer Key value
Most likely cause. Compare Salesforce Consumer Key against `SF_CONSUMER_KEY` in Netlify env. Look for trailing spaces, truncation, or transcription errors.

After fix, redeploy (drag-drop again or use Netlify CLI `netlify deploy --prod`).

### Fix #2 — Change SF_LOGIN_URL to My Domain URL
Some External Client Apps require org-specific My Domain URL as audience, not the generic test.salesforce.com.

- Change SF_LOGIN_URL from `https://test.salesforce.com` to `https://shelterfromthestorminc--dev.sandbox.my.salesforce.com`
- Redeploy

### Fix #3 — Wait 5-10 minutes
External Client Apps sometimes need propagation time. If app was created within the last 10 minutes, wait.

If all three fail, possibilities to investigate:
- External Client Apps may need a separate "publish" or "activate for OAuth" step beyond what we did
- Could fall back to creating a classic Connected App via metadata deploy (not UI) since Salesforce still supports them server-side

## When you resume

1. Read this doc
2. Try Fix #1 first (5 min)
3. Submit a fresh test form and check the Netlify function logs
4. If still failing, try Fix #2 (5 min)
5. If still failing, dig into External Client App docs OR consider classic Connected App fallback

The integration is 95% done. The remaining 5% is one debug session.
