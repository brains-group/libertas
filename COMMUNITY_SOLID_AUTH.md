# Community Solid Server Authentication Guide

Community Solid Server handles authentication differently than other Solid servers. It doesn't have a traditional "Authorized Applications" section.

## Authentication Methods

Community Solid Server supports:

1. **Password-based authentication** (what we're using)
   - Uses email and password
   - Should work for local development without explicit app authorization

2. **Client Credentials** (optional, for production)
   - Create tokens in "Credential tokens" section
   - More secure for server-to-server communication

## For Local Development

**Important**: Community Solid Server requires a **WebID to be linked** to your account for authentication to work.

### Linking a WebID

1. **Log into your account** at http://localhost:3000
2. **Go to your account page** (you should see it after login)
3. **Find "Registered Web IDs" section**
4. **Click "Link WebID"** button
5. **The server will generate a WebID** for you
6. **Note your WebID** - format: `http://localhost:3000/[identifier]/profile/card#me`

After linking a WebID, password-based authentication should work!

## Testing Authentication

Test if authentication works:

```bash
cd libertas-setup/solid-mpc
source venv/bin/activate
node test-auth.js config/encryption_agent.json
```

Or use the test script:
```bash
./scripts/test-authentication.sh
```

## If Authentication Fails

If password authentication doesn't work, you have two options:

### Option 1: Use Client Credentials (Recommended for Production)

1. **Log into your account** at http://localhost:3000
2. **Go to your account page** (you should see it after login)
3. **Find "Credential tokens" section**
4. **Click "Create token"** or similar button
5. **Give it a name**: "Libertas Encryption Agent"
6. **Copy the token/secret** generated

Then you would need to modify `data_fetcher.js` to use client credentials instead of password authentication.

### Option 2: Configure Server for Local Development

For local development, you can configure the server to be more permissive. However, the default configuration should work with password authentication.

## Current Setup

Your current configuration uses:
- **IDP**: `http://localhost:3000`
- **Username**: Your email address (e.g., `encryption-agent@localhost`)
- **Password**: Your password

This should work **without** needing to add trusted apps!

## Next Steps

1. **Test authentication**:
   ```bash
   ./scripts/test-authentication.sh
   ```

2. **If it works**: You're good to go! No need for trusted apps.

3. **If it fails**: 
   - Check that your email and password are correct
   - Verify the Solid server is running
   - Check the logs: `tail -f libertas-setup/solid-mpc/logs/solid-server.log`

## Important Notes

- **No "Authorized Applications" section**: Community Solid Server doesn't have this
- **Password auth works**: For local development, password authentication should work directly
- **Client credentials**: Optional, for more secure production setups
- **Permissions still needed**: You still need to grant read permissions to data resources

## Granting Permissions

Even without trusted apps, you still need to:

1. **Grant read permissions** on data resources
2. **Use the encryption agent's WebID** (from their profile)
3. **Set permission to Read** (not Write)

The WebID format: `http://localhost:3000/[identifier]/profile/card#me`

---

**For local development, password authentication should work without explicit app authorization!**

Try testing authentication first - it likely works already.

