# Community Solid Server Login Endpoints

This document lists all authentication-related endpoints for the Community Solid Server.

## Base URL

For local development: `http://localhost:3000`

## Main Endpoints

### 1. Login (Password-based)

**URL**: `http://localhost:3000/.account/login/password/`

**Method**: `POST`

**Fields**:
- `email` (required, string) - Your email address
- `password` (required, string) - Your password
- `remember` (optional, boolean) - Remember login session

**Example**:
```bash
curl -X POST http://localhost:3000/.account/login/password/ \
  -H "Content-Type: application/json" \
  -d '{"email":"encryption-agent@localhost","password":"test123"}'
```

### 2. Registration

**URL**: `http://localhost:3000/.account/login/password/register/`

**Method**: `POST`

**Fields**:
- `email` (required) - Email address for the account
- `password` (required) - Password
- `confirm password` (required) - Password confirmation

**Example**:
```bash
curl -X POST http://localhost:3000/.account/login/password/register/ \
  -H "Content-Type: application/json" \
  -d '{"email":"encryption-agent@localhost","password":"test123"}'
```

### 3. Forgot Password

**URL**: `http://localhost:3000/.account/login/password/forgot/`

**Method**: `POST`

**Fields**:
- `email` (required) - Email address to reset password for

### 4. Reset Password

**URL**: `http://localhost:3000/.account/login/password/reset/`

**Method**: `POST`

**Fields**:
- `token` (required) - Reset token from email
- `password` (required) - New password
- `confirm password` (required) - Password confirmation

### 5. Account Information

**URL**: `http://localhost:3000/.account/`

**Method**: `GET`

**Description**: Returns JSON with all available account controls and login methods.

**Example Response**:
```json
{
  "controls": {
    "password": {
      "forgot": "http://localhost:3000/.account/login/password/forgot/",
      "login": "http://localhost:3000/.account/login/password/",
      "reset": "http://localhost:3000/.account/login/password/reset/"
    },
    "account": {
      "create": "http://localhost:3000/.account/account/"
    },
    "main": {
      "logins": "http://localhost:3000/.account/login/",
      "index": "http://localhost:3000/.account/"
    }
  },
  "version": "0.5"
}
```

### 6. List Login Methods

**URL**: `http://localhost:3000/.account/login/`

**Method**: `GET`

**Description**: Returns available authentication methods.

## HTML Endpoints (for Browser Access)

For browser-based access, you can use these HTML endpoints:

- **Login Page**: `http://localhost:3000/.account/login/password/`
- **Registration Page**: `http://localhost:3000/.account/login/password/register/`
- **Forgot Password Page**: `http://localhost:3000/.account/login/password/forgot/`

## Programmatic Discovery

To discover all available endpoints programmatically:

```bash
curl http://localhost:3000/.account/
```

This returns a JSON object with all available controls and endpoints.

## For Libertas Configuration

In your `encryption_agent.json`, use:

```json
{
  "credential": {
    "idp": "http://localhost:3000",
    "username": "encryption-agent@localhost",
    "password": "test123"
  }
}
```

The `solid-node-client` library will automatically use the correct login endpoint based on the IDP URL.

## Notes

- All endpoints use the base URL: `http://localhost:3000`
- The server supports multiple authentication methods (password is the default)
- The JSON API provides dynamic discovery of available endpoints
- For production, consider using client credentials instead of password authentication

---

**Quick Reference**:
- Login: `http://localhost:3000/.account/login/password/`
- Register: `http://localhost:3000/.account/login/password/register/`
- Account Info: `http://localhost:3000/.account/`

