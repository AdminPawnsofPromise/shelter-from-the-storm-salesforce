# Website → Salesforce integration: one-time setup

This walks you through the ~30 minutes of manual setup needed to wire the Netlify Function to Salesforce. After this, every quick-intake form submission on sftsinc.com creates a Hotline_Call__c record in seconds — no manual re-entry.

**Per ADR-012.** Files are already in place in both repos:
- `sfts-site/netlify/functions/salesforce-intake.js`
- `sfts-site/package.json`
- `sfts-site/netlify.toml` (updated with `[functions]` block)

The setup has 4 phases.

---

## Phase 1 — Generate a JWT keypair (5 min)

We need a 2048-bit RSA keypair. The PUBLIC cert goes on the Salesforce Connected App; the PRIVATE key is a Netlify environment variable.

### Option A — Use OpenSSL (preferred)

If you have Git installed (you do — Git for Windows bundles `openssl`), open Git Bash and run:

```bash
# Generate a 2048-bit RSA private key
openssl genrsa -out sfts-website-private.key 2048

# Generate a self-signed certificate from the private key (valid 10 years)
openssl req -new -x509 -key sfts-website-private.key -out sfts-website-public.crt -days 3650 \
  -subj "/C=US/ST=Indiana/L=Greenfield/O=Shelter From the Storm Inc/CN=sfts-website-integration"
```

This produces two files:
- `sfts-website-private.key` — **NEVER commit, never share.** Goes in Netlify env vars only.
- `sfts-website-public.crt` — gets uploaded to Salesforce.

**Save both files somewhere safe.** A password manager or encrypted folder. Losing the private key means redoing this setup; leaking it means anyone can post to Salesforce as the integration user.

### Option B — Use an online generator
**Don't.** Generating a private key on a third-party website means giving them the keys to your data.

---

## Phase 2 — Configure Salesforce (15 min)

### 2a. Upload the certificate

1. In your **production** Salesforce org (`sfts-prod-DANGER`):
2. Setup → search "Certificate and Key Management"
3. Click **Create Self-Signed Certificate** → wait, no — we already have a cert.
4. Click **Import from Keystore** OR alternatively use **Upload Mutual Authentication Certificate**.

Actually, simpler path: use **Create CA-Signed Certificate** option, then in that flow you can upload your `.crt`:
- Setup → Certificate and Key Management → "Import from Keystore" doesn't take .crt files directly.

**The correct path for self-signed certs imported from outside:**
- Setup → Certificate and Key Management → **Create Self-Signed Certificate** (this is for new ones, but bear with me)

OK, the actual easiest path is to skip uploading the cert as a "Certificate" entry in Salesforce. Instead, on the Connected App config (step 2b), you'll **paste the certificate content directly**. This is supported.

### 2b. Create the Connected App

1. Setup → App Manager → **New Connected App**
2. Fill in:
   - Connected App Name: `SFTS Website Integration`
   - API Name: `SFTS_Website_Integration` (auto-fills)
   - Contact Email: `director@sftsinc.com`
3. **Enable OAuth Settings**: check the box.
4. Callback URL: `https://login.salesforce.com/services/oauth2/success`
   (Not actually used in JWT bearer flow but required by the form.)
5. **Use digital signatures**: check the box. Click "Choose File" and upload **`sfts-website-public.crt`** (from Phase 1).
6. Selected OAuth Scopes — move these to the right:
   - **Manage user data via APIs (api)**
   - **Perform requests at any time (refresh_token, offline_access)**
7. Save.

After saving, Salesforce shows a screen with the **Consumer Key** and **Consumer Secret**. Copy the **Consumer Key** (you'll need it in Phase 3). The secret isn't needed for JWT bearer flow.

### 2c. Pre-authorize the Connected App for the integration user

1. Setup → App Manager → find "SFTS Website Integration" → **▼ Manage**
2. Click **Edit Policies**
3. Under "OAuth Policies":
   - **Permitted Users**: change to **Admin approved users are pre-authorized**
4. Save.
5. Back on the Manage page, scroll to **Profiles** section → click **Manage Profiles** → check **System Administrator** → Save.
   - (Alternatively, scroll to **Permission Sets** and add `SFTS_Build_All_Access`.)

This means the integration user (`admin@sftsinc.com` in prod) is automatically authorized — no user-interactive OAuth needed.

### 2d. Confirm everything

In Setup → App Manager, the SFTS Website Integration row should show OAuth as enabled. Click "View" on the row → you should see the Consumer Key matches what you copied.

---

## Phase 3 — Configure Netlify environment variables (5 min)

1. In Netlify dashboard, go to your sftsinc.com site → **Site settings** → **Environment variables**
2. Add the following:

| Variable | Value | Notes |
|---|---|---|
| `SF_CONSUMER_KEY` | (paste the Consumer Key from Phase 2b) | ~85-char string |
| `SF_USERNAME` | `admin@sftsinc.com` | Your production admin username |
| `SF_LOGIN_URL` | `https://login.salesforce.com` | Production. Use `https://test.salesforce.com` if you ever point at sandbox. |
| `SF_PRIVATE_KEY` | (see below) | The private key contents |

**For `SF_PRIVATE_KEY`:**

Open `sfts-website-private.key` in a text editor. You'll see:
```
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAvK...
... many lines ...
-----END RSA PRIVATE KEY-----
```

Netlify's env var input is a single line. You need to replace every newline with the literal characters `\n` (backslash-n).

Easiest way: open Git Bash and run:
```bash
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0}' sfts-website-private.key
```

That outputs a single-line version. Copy that whole string and paste it as the `SF_PRIVATE_KEY` value in Netlify. The function will un-escape the `\n` back to real newlines.

---

## Phase 4 — Connect the Netlify Form to the function (5 min)

Netlify Forms by default just store submissions in the dashboard. To trigger our function:

1. Push the `sfts-site` changes to your site (deploy via your normal Netlify workflow — git push, drag-and-drop, or CLI). The function will deploy automatically with the site.
2. In Netlify dashboard → your site → **Forms** → click on the `quick-intake` form.
3. Click the **Settings & usage** tab.
4. Under **Form notifications**, click **Add notification** → choose **Outgoing webhook**.
5. Configure:
   - **Event to listen for**: New form submission
   - **URL to notify**: `https://YOUR-SITE.netlify.app/.netlify/functions/salesforce-intake`
   - (Or your custom domain: `https://sftsinc.com/.netlify/functions/salesforce-intake`)
6. Save.
7. Repeat for the `intake` form too (it'll log submissions only for v1; full handler is v2).

---

## Test it end-to-end (5 min)

1. Open your live site → /get-help.html → fill out the quick-intake form with synthetic data:
   - Name: "Test Survivor"
   - Phone: "317-555-9999"
   - Best time: "afternoons"
   - Safe to call: "Yes, leave a message"
   - Note: "Webhook test — please ignore"
2. Submit.
3. In Netlify dashboard → **Functions** → `salesforce-intake` — you should see a recent invocation. Click it for logs.
4. In Salesforce, go to **Hotline Calls** tab → there should be a new HC-XXXXX record with the form data populated.

**If it works:** delete the test record. You're done. Every future submission auto-flows.

**If it fails:**
- Check the function logs in Netlify (most informative)
- Common issues:
  - `SF_CONSUMER_KEY` mismatch → verify in Salesforce App Manager
  - `SF_USERNAME` not pre-authorized → recheck Phase 2c
  - `SF_PRIVATE_KEY` malformed → the `\n` escaping is finicky; try the `awk` command again
  - "Invalid JWT signature" → the public cert in Phase 2b doesn't match the private key in Phase 3

---

## Operational notes

- **Latency:** typical end-to-end is 1–3 seconds from form submit to Salesforce record.
- **Failure mode:** if Salesforce is down or auth fails, Netlify Forms still preserves the submission in its dashboard. You can replay manually.
- **Volume:** Netlify Functions free tier covers 125,000 invocations/month. SFTS will not hit this.
- **Cost:** $0 ongoing.
- **Security:** the private key never leaves Netlify's env vars; the function never logs sensitive data; HTTPS end-to-end.

## When this needs revisiting

- Connected App / Profile changes → may need to re-grant the integration user
- Salesforce password reset on `admin@sftsinc.com` → JWT bearer flow doesn't care about passwords (uses keys), so password resets don't break the integration
- Sandbox vs Prod switch → change `SF_LOGIN_URL` and re-deploy Connected App in the new org
- Adding new fields to the form → update the field mapping in `salesforce-intake.js`
- v2: extending to the full intake form → implement the `formName === 'intake'` branch in `salesforce-intake.js`
