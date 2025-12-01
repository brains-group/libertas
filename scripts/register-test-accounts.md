# Registering Test Accounts on Local Solid Server

The Community Solid Server uses **email-based registration** instead of usernames.

## Registration Process

### Step 1: Register Encryption Agent

1. Go to: http://localhost:3000/.account/login/password/register/
2. Fill in the form:
   - **Email**: `encryption-agent@localhost` (or any email format you prefer)
   - **Password**: `test123` (or your preferred password)
   - **Confirm password**: Same password
3. Click **"Register"**
4. **Note**: The server will create a Pod based on your email
5. **Your WebID** will be something like:
   - `http://localhost:3000/[email-slug]/profile/card#me`
   - Or check your profile after registration

### Step 2: Register Data Provider

1. Log out (if logged in)
2. Go to: http://localhost:3000/.account/login/password/register/
3. Fill in:
   - **Email**: `data-provider@localhost`
   - **Password**: Choose a password
   - **Confirm password**: Same password
4. Click **"Register"**

### Step 3: Register Requestor (Optional)

1. Email: `requestor@localhost`
2. Password: Choose a password
3. Register

## Finding Your WebID

After registration:

1. Log into your account
2. Go to your profile or account settings
3. Your WebID will be displayed, typically in the format:
   ```
   http://localhost:3000/[identifier]/profile/card#me
   ```

Or check the URL when viewing your profile card.

## Updating Libertas Configuration

After registering the encryption agent:

1. **Find the WebID** from your profile
2. **Update the configuration**:
   ```bash
   ./scripts/configure-credentials.sh
   ```
   - IDP: `http://localhost:3000`
   - Username: Use the **email address** you registered with
   - Password: The password you set

**Note**: The "username" field in the config should be your **email address**, not a username.

## Example Configuration

After registering with email `encryption-agent@localhost`:

```json
{
  "credential": {
    "idp": "http://localhost:3000",
    "username": "encryption-agent@localhost",
    "password": "test123"
  }
}
```

## Tips

- Use simple email formats like `name@localhost` for easy testing
- The server will create a Pod identifier from your email
- Your WebID format may vary based on server configuration
- Check your profile page to see your exact WebID

