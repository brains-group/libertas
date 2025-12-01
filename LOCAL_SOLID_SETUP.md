# Local Solid Server Setup for Libertas

This guide helps you set up a local Solid IDP and Pod server for seamless end-to-end testing with Libertas.

## Overview

Setting up a local Solid server allows you to:
- Test Libertas without external dependencies
- Develop and debug in a controlled environment
- Have full control over Pod data and permissions
- Avoid rate limits and network issues

## Quick Start

```bash
# 1. Set up local Solid server
./scripts/setup-local-solid.sh

# 2. Start the Solid server
./scripts/start-solid-server.sh

# 3. Configure Libertas to use local IDP
./scripts/configure-local-idp.sh test-user

# 4. Register account at http://localhost:3000
# 5. Add trusted app and grant permissions
# 6. Start Libertas services
./scripts/start-services.sh
```

## Detailed Setup

### Step 1: Install Local Solid Server

Run the setup script:

```bash
./scripts/setup-local-solid.sh
```

This will:
- Clone Community Solid Server
- Install dependencies
- Create configuration files
- Set up data directories

**Time**: ~5-10 minutes (depending on network speed)

### Step 2: Start Solid Server

Start the server:

```bash
./scripts/start-solid-server.sh
```

Or manually:
```bash
cd libertas-setup/community-solid-server
npm start
```

The server will start on: **http://localhost:3000**

### Step 3: Register Test Accounts

1. **Open browser**: http://localhost:3000
2. **Click "Register"** or "Sign up"
3. **Create accounts** (using EMAIL addresses):
   - **Encryption Agent**: `encryption-agent@localhost` (or any email format)
   - **Data Provider**: `data-provider@localhost`
   - **Computation Requestor**: `requestor@localhost`

4. **Note the WebIDs** (check your profile after registration):
   - Format: `http://localhost:3000/[identifier]/profile/card#me`
   - The identifier is derived from your email address
   - Check your profile page for the exact WebID

### Step 4: Configure Trusted Applications

For the **Encryption Agent** account:

1. Log into http://localhost:3000 as `encryption-agent`
2. Go to **Account Settings** → **Authorized Applications**
3. Add: `https://solid-node-client`
4. Click **Authorize**

### Step 5: Configure Libertas

Update Libertas to use the local IDP:

```bash
./scripts/configure-local-idp.sh encryption-agent@localhost
```

Or use the interactive script:
```bash
./scripts/configure-credentials.sh
```

This updates `encryption_agent.json` with:
- IDP: `http://localhost:3000`
- Username: `encryption-agent@localhost` (your EMAIL address)

### Step 6: Set Up Data and Permissions

1. **Log in as Data Provider**:
   - Go to: http://localhost:3000
   - Log in as `data-provider`

2. **Upload/Create Data**:
   - Create a data file (e.g., `data.csv`)
   - Note the URL (e.g., `http://localhost:3000/data-provider/data.csv`)

3. **Grant Permissions**:
   - Click the lock icon (🔒) on the data file
   - Add agent: `http://localhost:3000/encryption-agent/profile/card#me`
   - Set permission to **Read**
   - Save

4. **Create Preference Document**:
   - Create `preferences.ttl` in your Pod
   - Use the template from `examples/preference-example.ttl`
   - Update URLs to use `http://localhost:8000`, `http://localhost:8010`, etc.

5. **Create Resource Description**:
   - Create `resource-description.ttl`
   - Use template from `examples/resource-description-example.ttl`
   - Update with your local Pod URLs

### Step 7: Start Libertas Services

```bash
./scripts/start-services.sh
```

### Step 8: Test End-to-End

1. **Access MPC App**: http://localhost:5173
2. **Log in** (optional) as computation requestor
3. **Input Resource Description URL**: 
   ```
   http://localhost:3000/data-provider/resource-description.ttl
   ```
4. **Select computation** and run!

## Configuration Files

### Solid Server Configuration

Location: `libertas-setup/community-solid-server/config/config.json`

```json
{
  "port": 3000,
  "baseUrl": "http://localhost:3000",
  "rootFilePath": "./data",
  "enableWebId": true,
  "identityProvider": {
    "enabled": true
  }
}
```

### Libertas Configuration

Location: `libertas-setup/solid-mpc/config/encryption_agent.json`

```json
{
  "credential": {
    "idp": "http://localhost:3000",
    "username": "encryption-agent",
    "password": "your-password"
  },
  "base_dir": "/path/to/MP-SPDZ"
}
```

## Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Solid Server | http://localhost:3000 | IDP and Pod server |
| Encryption Agent 1 | http://localhost:8000 | Secret sharing |
| Encryption Agent 2 | http://localhost:8001 | Secret sharing |
| Computation Agent 1 | http://localhost:8010 | MPC computation |
| Computation Agent 2 | http://localhost:8011 | MPC computation |
| Computation Agent 3 | http://localhost:8012 | MPC computation |
| MPC App | http://localhost:5173 | User interface |

## Example WebIDs

With local server at `http://localhost:3000`:

**Note**: WebIDs are generated from email addresses. Check your profile after registration for exact WebIDs.

- Format: `http://localhost:3000/[identifier]/profile/card#me`
- The identifier is derived from your email address
- Example emails: `encryption-agent@localhost`, `data-provider@localhost`

## Troubleshooting

### Solid Server Won't Start

1. **Check port 3000**:
   ```bash
   lsof -i :3000
   ```

2. **Check Node.js version**:
   ```bash
   node -v  # Should be 18+
   ```

3. **Reinstall dependencies**:
   ```bash
   cd libertas-setup/community-solid-server
   rm -rf node_modules
   npm install
   ```

### Authentication Fails

1. **Verify Solid server is running**:
   ```bash
   curl http://localhost:3000
   ```

2. **Check credentials** in `encryption_agent.json`

3. **Verify trusted app** is added in account settings

4. **Check account exists**:
   - Go to: http://localhost:3000
   - Try logging in manually

### Permission Errors

1. **Verify WebID format**:
   ```
   http://localhost:3000/username/profile/card#me
   ```

2. **Check permissions** on data resources:
   - Log into Pod as data provider
   - Check access control on data file
   - Ensure encryption agent WebID has Read permission

### Data Not Accessible

1. **Check file URL** is correct
2. **Verify permissions** are set
3. **Test access** manually in browser (while logged in as encryption agent)

## Advanced Configuration

### Custom Port

Edit `libertas-setup/community-solid-server/config/config.json`:
```json
{
  "port": 4000,
  "baseUrl": "http://localhost:4000"
}
```

Then update Libertas config accordingly.

### Persistent Data

Data is stored in: `libertas-setup/community-solid-server/data/`

To reset:
```bash
rm -rf libertas-setup/community-solid-server/data/*
```

### Multiple Pods

Create multiple accounts in the Solid server, each gets their own Pod space.

## Integration with Libertas

The local setup integrates seamlessly:

1. **Encryption Agent** authenticates to local IDP
2. **Fetches data** from local Pods
3. **Performs secret sharing** to computation agents
4. **Returns results** via MPC App

All services run locally for complete end-to-end testing!

## Next Steps

After local setup:

1. ✅ Test authentication
2. ✅ Create test data
3. ✅ Set up permissions
4. ✅ Run test computations
5. ✅ Develop and debug locally

---

**Local Solid Server**: http://localhost:3000  
**MPC App**: http://localhost:5173

Enjoy seamless local development! 🚀

