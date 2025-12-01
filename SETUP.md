# Libertas Setup and Run Guide

Complete guide to set up and run the Libertas privacy-preserving computation framework.

## Prerequisites

- Git (with submodule support)
- Python 3.8+
- Node.js 18+ (required for Community Solid Server)
- Homebrew (macOS) or equivalent package manager

**Note**: See [SUBMODULES.md](./SUBMODULES.md) for detailed information about git submodules setup.

## Quick Start

```bash
# 1. Clone and setup
./setup.sh
./scripts/setup-services.sh

# 2. Configure credentials
./scripts/configure-credentials.sh

# 3. Start services
./scripts/start-services.sh

# 4. Access MPC App
open http://localhost:5173
```

## Detailed Setup

### Step 1: Initial Setup

#### Option A: Using Git Submodules (Recommended)

If this repository uses git submodules, initialize them:

```bash
# Clone the main repository with submodules
git clone --recursive https://github.com/OxfordHCC/libertas.git
cd libertas

# Or if already cloned, initialize submodules
git submodule update --init --recursive
```

This will clone:
- `solid-mpc-app` (MPC App) → `libertas-setup/solid-mpc-app`
- `solid-mpc` (Agent Services) → `libertas-setup/solid-mpc`
- `MP-SPDZ` (MPC Framework) → `libertas-setup/MP-SPDZ`
- `community-solid-server` (Local Solid Server) → `libertas-setup/community-solid-server`

#### Option B: Using Setup Script

Run the main setup script to clone repositories:

```bash
chmod +x setup.sh
./setup.sh
```

This will:
- Clone `solid-mpc-app` (MPC App)
- Clone `solid-mpc` (Agent Services)
- Create example configuration files

**Note**: MP-SPDZ and Community Solid Server are cloned separately by their respective setup scripts.

### Step 2: Install Dependencies

Install all required dependencies:

```bash
./scripts/setup-services.sh
```

This will:
- Create Python virtual environment
- Install Python dependencies (FastAPI, uvicorn, etc.)
- Install Node.js dependencies for agent services
- Install Node.js dependencies for MPC App
- Build MP-SPDZ framework
- Create configuration files

### Step 3: Configure Encryption Agent

Configure your encryption agent credentials:

```bash
./scripts/configure-credentials.sh
```

You'll need:
- **IDP URL**: Your Solid Pod provider (e.g., `https://login.inrupt.com`)
- **Username**: Your Pod username
- **Password**: Your Pod password

**Configuration file**: `libertas-setup/solid-mpc/config/encryption_agent.json`

### Step 4: Set Up WebID

1. **Register/Log in** at your Pod provider (e.g., https://login.inrupt.com)

2. **Add Trusted Application**:
   - Go to Account Settings → Authorized Applications
   - Add: `https://solid-node-client`
   - Authorize the application

3. **Your WebID** will be:
   ```
   https://[your-idp]/[your-username]/profile/card#me
   ```

4. **Grant Permissions**:
   - For each data resource, grant your encryption agent's WebID **read** permission
   - Use the lock icon (🔒) or "Manage Access" on the resource

### Step 5: Verify Setup

Verify everything is configured correctly:

```bash
./scripts/verify-setup.sh
```

This checks:
- All repositories are cloned
- Dependencies are installed
- MP-SPDZ is built
- Configuration files exist
- Credentials are configured

## Running Libertas

### Start All Services

```bash
./scripts/start-services.sh
```

This starts:
- 2 Encryption Agents (ports 8000, 8001)
- 3 Computation Agents (ports 8010, 8011, 8012)
- MPC App (port 5173)

### Check Service Status

```bash
./scripts/check-services.sh
```

### Stop Services

```bash
./scripts/stop-services.sh
```

### Access MPC App

Open in your browser:
```
http://localhost:5173
```

## Using the MPC App

1. **Log in** (optional) with your WebID
2. **Input Resource Description URL**: URL to your resource description document
3. **Select Computation**: Choose the MPC computation type
4. **Run**: Start the computation and monitor progress

## Configuration Files

### Encryption Agent
`libertas-setup/solid-mpc/config/encryption_agent.json`
```json
{
  "credential": {
    "idp": "https://login.inrupt.com",
    "username": "your-username",
    "password": "your-password"
  },
  "base_dir": "/path/to/MP-SPDZ",
  "allowed_origins": ["*"]
}
```

### Computation Agent
`libertas-setup/solid-mpc/config/computation_agent.json`
```json
{
  "base_dir": "/path/to/MP-SPDZ",
  "allowed_origins": ["*"]
}
```

## Creating Configuration Documents

### Preference Document

Generate a template:
```bash
./scripts/generate-preference.sh my-preference.ttl
```

Example structure:
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
          :userId "https://login.inrupt.com/username/profile/card#me" ].
```

### Resource Description

Generate a template:
```bash
./scripts/generate-resource-desc.sh my-resource-desc.ttl
```

Example structure:
```turtle
@prefix : <urn:solid:mpc#>.

:sources a :MPCSourceSpec;
  :source :src1.

:src1 a :MPCSource;
  :pref <https://pod.example.com/preferences.ttl>;
  :data <https://pod.example.com/data.csv>.
```

## Service Management

### View Logs

```bash
# Encryption Agents
tail -f libertas-setup/solid-mpc/logs/encryption-8000.log
tail -f libertas-setup/solid-mpc/logs/encryption-8001.log

# Computation Agents
tail -f libertas-setup/solid-mpc/logs/computation-8010.log

# MPC App
tail -f libertas-setup/solid-mpc/logs/mpc-app.log
```

### Restart Services

```bash
./scripts/stop-services.sh
./scripts/start-services.sh
```

### Individual Service Control

```bash
# Start only encryption agents
./scripts/start-services.sh encryption

# Start only computation agents
./scripts/start-services.sh computation

# Start only MPC app
./scripts/start-services.sh app
```

## Troubleshooting

### Services Won't Start

1. Check ports are available:
   ```bash
   lsof -i :8000 -i :8001 -i :8010 -i :8011 -i :8012
   ```

2. Verify setup:
   ```bash
   ./scripts/verify-setup.sh
   ```

3. Check logs for errors:
   ```bash
   tail -50 libertas-setup/solid-mpc/logs/*.log
   ```

### Authentication Fails

1. Verify credentials:
   ```bash
   cat libertas-setup/solid-mpc/config/encryption_agent.json
   ```

2. Check trusted app is added at your Pod provider

3. Test login manually at your Pod provider

### Permission Errors

1. Verify encryption agent WebID has read permission on data resources

2. Check WebID format is correct:
   ```
   https://[idp]/[username]/profile/card#me
   ```

3. Re-grant permissions if needed

## Directory Structure

```
libertas/
├── setup.sh                    # Main setup script
├── SETUP.md                    # This file
├── scripts/                    # Helper scripts
│   ├── setup-services.sh      # Install dependencies
│   ├── start-services.sh      # Start services
│   ├── stop-services.sh        # Stop services
│   ├── check-services.sh      # Check status
│   ├── configure-credentials.sh # Configure credentials
│   ├── verify-setup.sh         # Verify setup
│   ├── generate-preference.sh # Generate preference doc
│   └── generate-resource-desc.sh # Generate resource desc
├── examples/                   # Example configuration files
├── libertas-setup/            # Setup directory
│   ├── solid-mpc/             # Agent services
│   ├── solid-mpc-app/         # MPC App
│   └── MP-SPDZ/               # MP-SPDZ framework
└── spec/                      # Specification
```

## Next Steps

After setup and starting services:

1. Create preference documents for data providers
2. Create resource description for MPC App
3. Configure Solid Pod permissions
4. Run your first MPC computation!

## Additional Resources

- **Specification**: `spec/index.html`
- **MP-SPDZ Docs**: https://mp-spdz.readthedocs.io/
- **Paper**: https://arxiv.org/abs/2309.16365

---

**Need help?** Check service logs or run `./scripts/verify-setup.sh` for diagnostics.

