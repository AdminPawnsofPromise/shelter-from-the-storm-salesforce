# Integration Setup — In-Progress Snapshot

**Status as of Day 7 morning:** mid-way through wiring the Netlify website integration. If we lose conversation context, this doc lets us pick up exactly where we left off.

## Where we are

### ✅ Phase 1 — JWT keypair generated (DONE)
Files exist at `C:\Users\tzadi\Documents\CLAUDE\SFTS\secrets\`:
- `sfts-website-private.key` — the secret (~1732 bytes)
- `sfts-website-public.crt` — the public cert (~1418 bytes)
- Generated via OpenSSL in Git Bash
- Validity: 5/14/2026 to 5/11/2036
- Subject: `/C=US/ST=Indiana/L=Greenfield/O=Shelter From the Storm Inc/CN=sfts-website-integration`

### ✅ Phase 2 — External Client App created in sandbox (DONE)
Sandbox org: `sfts-dev` (`admin@sftsinc.com.dev`, org ID `00DWr00000BgbeLMAR`)

External Client App name: **SFTS Website Integration**
- Contact Email: director@sftsinc.com
- OAuth enabled, JWT Bearer Flow enabled
- Cert uploaded: `sfts-website-public.crt`
- Callback URL: `https://login.salesforce.com/services/oauth2/success` (not used for JWT bearer, just required field)
- OAuth Scopes selected:
  - Manage user data via APIs (api)
  - Perform requests at any time (refresh_token, offline_access)
- Permitted Users: **Admin approved users are pre-authorized**
- Authorized profile: **System Administrator**

**Note:** Salesforce no longer offers "Connected App" creation in UI — we used the newer "External Client App" pattern. Same JWT bearer auth, slightly different config screens.

### ⏳ Phase 2B — Get Consumer Key (IN PROGRESS)
**Where to find it:** the External Client App detail page, **Settings tab**, OAuth Settings subsection.
- May be hidden behind a "Manage Consumer Details" button that re-prompts for password/MFA.
- Copy the Consumer Key value (long alphanumeric string ~85 chars).
- Save it locally for Phase 3.

### ⬜ Phase 3 — Set 4 Netlify env vars (TODO)
In Netlify dashboard → sftsinc.com site → Site settings → Environment variables. Add:

| Variable | Value |
|---|---|
| `SF_CONSUMER_KEY` | Paste the Consumer Key from Phase 2B |
| `SF_USERNAME` | `admin@sftsinc.com.dev` (sandbox username — note `.dev` suffix) |
| `SF_LOGIN_URL` | `https://test.salesforce.com` (sandbox; for prod use `https://login.salesforce.com`) |
| `SF_PRIVATE_KEY` | Contents of `sfts-website-private.key` with newlines as literal `\n` |

To convert private key to single-line: in Git Bash, run
```bash
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0}' ~/Documents/CLAUDE/SFTS/secrets/sfts-website-private.key
```

### ⬜ Phase 4 — Push updated website to Netlify (TODO)
Files modified in `C:\Users\tzadi\Documents\CLAUDE\SFTS\sfts-site\`:
- `get-help.html` — added 4 new intake form fields (abuser nearby, weapons, relationship, urgent need)
- `netlify/functions/salesforce-intake.js` — handles both quick-intake and full intake forms
- `netlify.toml` — added `[functions]` block
- `package.json` — declares jsonwebtoken dependency

Deploy via Daniel's normal Netlify workflow (git push to connected GitHub, drag-and-drop, or Netlify CLI).

### ⬜ Phase 5 — Wire form webhook in Netlify (TODO)
1. Netlify dashboard → site → **Forms**
2. Click `quick-intake` form → Settings & usage tab
3. Form notifications → Add notification → Outgoing webhook
4. Event: New form submission
5. URL: `https://sftsinc.com/.netlify/functions/salesforce-intake`
6. Save
7. Repeat for the `intake` form

### ⬜ Phase 6 — End-to-end test (TODO)
1. Open sftsinc.com/get-help.html
2. Submit quick-intake with synthetic data ("Test Survivor", "317-555-9999")
3. In Netlify dashboard → Functions → `salesforce-intake` — verify successful invocation
4. In sandbox Salesforce → Hotline Calls tab → newest record should be the test
5. Delete the test record when verified

## Production cutover

After end-to-end test passes in sandbox: see `docs/08-production-cutover-plan.md`.

Key differences for prod:
- Create a SEPARATE External Client App in production (sfts-prod-DANGER)
- Generate a fresh keypair OR reuse the sandbox one (your choice)
- Change Netlify env vars: SF_LOGIN_URL=https://login.salesforce.com, SF_USERNAME=admin@sftsinc.com, SF_CONSUMER_KEY=new prod key

## If we resume in a fresh conversation

1. Read this doc + `docs/06-netlify-integration-setup.md`
2. Confirm Daniel's status on each phase
3. Resume at the next ⬜ phase

The git history has all the metadata changes. The Connected App lives in Salesforce. The keypair lives on Daniel's disk. Conversation context isn't load-bearing for any of those.
