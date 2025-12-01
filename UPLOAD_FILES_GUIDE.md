# How to Upload Files to Community Solid Server Pod

Community Solid Server doesn't have a built-in file upload UI in the web interface. You need to use HTTP PUT requests to upload files. Here are several methods:

## Method 1: Automated Script (Recommended)

Use the provided script to upload files automatically:

```bash
./scripts/upload-files-to-pod.sh [password]
```

This script will:
1. Authenticate with your credentials
2. Upload all test data files to your Pod
3. Verify the uploads

**Example:**
```bash
./scripts/upload-files-to-pod.sh your-password
```

## Method 2: Manual HTTP PUT with curl

You can upload files directly using `curl` with HTTP PUT:

### Step 1: Authenticate and Get Session

First, authenticate to get a session cookie:

```bash
# Create a cookie jar file
COOKIE_JAR=$(mktemp)

# Authenticate
curl -c "$COOKIE_JAR" -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"data-provider@localhost","password":"your-password"}' \
  http://localhost:3000/.account/login/password/
```

### Step 2: Upload Files

Then upload each file using the session cookie:

```bash
# Upload data.csv
curl -b "$COOKIE_JAR" -X PUT \
  -H "Content-Type: text/csv" \
  -H "Slug: data.csv" \
  --data-binary "@test-data/data.csv" \
  http://localhost:3000/data-provider/data.csv

# Upload preferences.ttl
curl -b "$COOKIE_JAR" -X PUT \
  -H "Content-Type: text/turtle" \
  -H "Slug: preferences.ttl" \
  --data-binary "@test-data/preferences.ttl" \
  http://localhost:3000/data-provider/preferences.ttl

# Upload resource-description.ttl
curl -b "$COOKIE_JAR" -X PUT \
  -H "Content-Type: text/turtle" \
  -H "Slug: resource-description.ttl" \
  --data-binary "@test-data/resource-description.ttl" \
  http://localhost:3000/data-provider/resource-description.ttl

# Clean up
rm "$COOKIE_JAR"
```

## Method 3: Using Basic Authentication

You can also try using Basic Authentication directly:

```bash
# Upload data.csv
curl -X PUT \
  -H "Content-Type: text/csv" \
  -H "Slug: data.csv" \
  --user "data-provider@localhost:your-password" \
  --data-binary "@test-data/data.csv" \
  http://localhost:3000/data-provider/data.csv
```

**Note:** Basic auth may not work depending on your server configuration. Session-based auth (Method 2) is more reliable.

## Method 4: Using a Solid Client Library

For programmatic access, you can use a Solid client library:

### Using solid-file-client (Node.js)

```bash
npm install solid-file-client solid-auth-cli
```

```javascript
const SolidFileClient = require('solid-file-client');
const auth = require('solid-auth-cli');

const fc = new SolidFileClient(auth);

async function uploadFile() {
  try {
    await auth.login({
      idp: 'http://localhost:3000',
      username: 'data-provider@localhost',
      password: 'your-password'
    });

    await fc.putFile(
      'http://localhost:3000/data-provider/data.csv',
      'test-data/data.csv',
      'text/csv'
    );
    
    console.log('File uploaded successfully!');
  } catch (err) {
    console.error('Error:', err);
  }
}

uploadFile();
```

## Verification

After uploading, verify the files are accessible:

```bash
# Check if files exist
curl http://localhost:3000/data-provider/data.csv
curl http://localhost:3000/data-provider/preferences.ttl
curl http://localhost:3000/data-provider/resource-description.ttl
```

Or open them in your browser:
- http://localhost:3000/data-provider/data.csv
- http://localhost:3000/data-provider/preferences.ttl
- http://localhost:3000/data-provider/resource-description.ttl

## Troubleshooting

### HTTP 401 (Unauthorized)
- Make sure you're authenticated
- Check your email and password
- Verify your WebID is linked to your account

### HTTP 403 (Forbidden)
- Check that you have write permissions to the Pod
- Verify the Pod path is correct

### HTTP 404 (Not Found)
- Make sure the Pod exists
- Check the URL path is correct

### HTTP 409 (Conflict)
- File already exists
- Delete the existing file first or use a different name

## Next Steps

After uploading files:

1. **Grant Read Permissions**:
   - Log into http://localhost:3000
   - Click the lock icon (🔒) on each file
   - Add: `http://localhost:3000/encryption-agent/profile/card#me`
   - Set permission to **Read**
   - Save

2. **Run the Demo**:
   - Open: http://localhost:5173
   - Input Resource Description URL: `http://localhost:3000/data-provider/resource-description.ttl`
   - Select computation type and run!

---

**Quick Reference:**
- Upload script: `./scripts/upload-files-to-pod.sh`
- Test data location: `test-data/`
- Pod URL: `http://localhost:3000/data-provider/`

