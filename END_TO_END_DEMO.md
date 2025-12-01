# End-to-End Demo Setup Guide

This guide walks you through setting up a complete end-to-end demo of Libertas with a local Solid server.

## Current Status

✅ **Automated Steps Completed:**
- Local Solid server started on http://localhost:3000
- Libertas configured to use local IDP
- All Libertas services started

## Manual Steps Required

### Step 1: Register Test Accounts

1. **Open browser**: http://localhost:3000

2. **Register Encryption Agent**:
   - Go to: http://localhost:3000/.account/login/password/register/
   - **Email**: `encryption-agent@localhost` (or any email format)
   - **Password**: `test123` (or your preferred password)
   - **Confirm password**: Same password
   - Click "Register"
   - **Note**: After registration, check your profile for your exact WebID
   - **WebID format**: `http://localhost:3000/[identifier]/profile/card#me`

3. **Register Data Provider**:
   - Log out (if logged in)
   - Go to: http://localhost:3000/.account/login/password/register/
   - **Email**: `data-provider@localhost`
   - **Password**: Choose a password
   - **Confirm password**: Same password
   - Click "Register"
   - **Note**: Check your profile for your exact WebID

4. **Register Computation Requestor** (optional):
   - **Email**: `requestor@localhost`
   - **Password**: Choose a password
   - Register

### Step 2: Configure Encryption Agent Account

**Important**: Community Solid Server doesn't have "Authorized Applications". It uses password authentication directly.

1. **Log in as encryption-agent**:
   - Go to: http://localhost:3000
   - Log in with your email: `encryption-agent@localhost` (or the email you used)

2. **Link a WebID** (if not already linked):
   - On your account page, find "Registered Web IDs" section
   - Click "Link WebID"
   - The server will create/generate a WebID for you
   - **Note your WebID** - you'll need it for permissions

3. **Update Libertas Configuration**:
   ```bash
   ./scripts/configure-credentials.sh
   ```
   - IDP: `http://localhost:3000`
   - **Username**: Use your **EMAIL ADDRESS** (e.g., `encryption-agent@localhost`)
   - Password: (the password you set)
   
   **Important**: 
   - The "username" field should be your email address
   - Community Solid Server doesn't have "Authorized Applications"
   - You need to **link a WebID** to your account first (see step 2)

### Step 3: Create Test Data

1. **Log in as data-provider**:
   - Go to: http://localhost:3000
   - Log in with username: `data-provider`

2. **Upload/Create Data File**:
   - Create a simple CSV file with test data, e.g.:
     ```csv
     1,2,3,4,5
     6,7,8,9,10
     ```
   - Upload it to your Pod or create it directly
   - **Note the URL**: e.g., `http://localhost:3000/data-provider/data.csv`

3. **Grant Permissions**:
   - Click the lock icon (🔒) on the data file
   - Or right-click → "Manage Access"
   - Add agent: Use the encryption agent's WebID (check their profile)
   - Format: `http://localhost:3000/[identifier]/profile/card#me`
   - Set permission to **Read**
   - Click "Save"

### Step 4: Create Preference Document

1. **Still logged in as data-provider**, create a preference document:

   Create file: `preferences.ttl` in your Pod with:
   ```turtle
   @prefix : <urn:solid:mpc#>
   @prefix schema: <https://schema.org/>

   []
       :trustedComputationServer
           [ schema:url "http://localhost:8010" ],
           [ schema:url "http://localhost:8011" ],
           [ schema:url "http://localhost:8012" ];
       :trustedEncryptionServer
           [ schema:url "http://localhost:8000";
             :userId "http://localhost:3000/encryption-agent/profile/card#me" ].
   ```

   **Note the URL**: e.g., `http://localhost:3000/data-provider/preferences.ttl`

2. **Grant Read Permission** to the preference document:
   - Click lock icon on `preferences.ttl`
   - Add: `http://localhost:3000/requestor/profile/card#me` (or public read)
   - Set to **Read**
   - Save

### Step 5: Create Resource Description

1. **Create resource description** for the MPC App:

   Create file: `resource-description.ttl`:
   ```turtle
   @prefix : <urn:solid:mpc#>.

   :sources a :MPCSourceSpec;
     :source :src1.

   :src1 a :MPCSource;
     :pref <http://localhost:3000/data-provider/preferences.ttl>;
     :data <http://localhost:3000/data-provider/data.csv>.
   ```

   **Note the URL**: e.g., `http://localhost:3000/data-provider/resource-description.ttl`

2. **Grant Read Permission** (public or to requestor)

### Step 6: Test the Demo

1. **Access MPC App**: http://localhost:5173

2. **Log in** (optional) as `requestor`:
   - Click "Log in" in the MPC App
   - Use: `http://localhost:3000/requestor/profile/card#me`

3. **Input Resource Description**:
   - Paste: `http://localhost:3000/data-provider/resource-description.ttl`

4. **Select Computation**:
   - Choose a computation type (e.g., sum, average)
   - Configure parameters

5. **Run Computation**:
   - Click "Run" or "Start"
   - Monitor progress
   - View results!

## Quick Reference

### Service URLs
- **Solid Server**: http://localhost:3000
- **MPC App**: http://localhost:5173
- **Encryption Agents**: http://localhost:8000, 8001
- **Computation Agents**: http://localhost:8010, 8011, 8012

### Test Accounts (Email-based)
- **Encryption Agent**: `encryption-agent@localhost` @ http://localhost:3000
- **Data Provider**: `data-provider@localhost` @ http://localhost:3000
- **Requestor**: `requestor@localhost` @ http://localhost:3000

### WebIDs
**Note**: WebIDs are generated from your email. Check your profile after registration for exact WebIDs.
- Format: `http://localhost:3000/[identifier]/profile/card#me`
- The identifier is derived from your email address

## Troubleshooting

### Solid Server Not Running
```bash
# Check if running
lsof -i :3000

# Start it
./scripts/start-solid-server.sh
```

### Authentication Fails
1. Verify credentials in `encryption_agent.json`
2. Check trusted app is added
3. Test login manually at http://localhost:3000

### Permission Errors
1. Verify encryption agent WebID has read permission
2. Check WebID format is correct
3. Re-grant permissions if needed

### Services Not Running
```bash
# Check status
./scripts/check-services.sh

# Restart
./scripts/stop-services.sh
./scripts/start-services.sh
```

## Verification Checklist

- [ ] Solid server running on port 3000
- [ ] Test accounts created
- [ ] Trusted app added for encryption-agent
- [ ] Libertas credentials configured
- [ ] Data file created and permissions set
- [ ] Preference document created
- [ ] Resource description created
- [ ] All Libertas services running
- [ ] MPC App accessible
- [ ] Can run test computation

---

**You're ready for the demo!** 🚀

Follow the steps above to complete the manual setup, then test the end-to-end flow.

