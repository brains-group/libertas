# Libertas Helper Scripts

This directory contains helper scripts for setting up and managing Libertas.

## Setup Scripts

### `setup-services.sh`
Installs all dependencies and sets up the system.
- Creates Python virtual environment
- Installs Python and Node.js dependencies
- Builds MP-SPDZ
- Creates configuration files

**Usage**: `./scripts/setup-services.sh`

## Configuration Scripts

### `configure-credentials.sh`
Interactive script to configure encryption agent credentials.
- Updates IDP (Identity Provider) URL
- Updates username and password
- Creates backup of configuration

**Usage**: `./scripts/configure-credentials.sh`

### `generate-preference.sh [output-file]`
Generates a preference document template.

**Usage**: `./scripts/generate-preference.sh my-preference.ttl`

### `generate-resource-desc.sh [output-file]`
Generates a resource description template.

**Usage**: `./scripts/generate-resource-desc.sh my-resource-desc.ttl`

## Service Management Scripts

### `start-services.sh [service]`
Starts all or individual services.
- `all` (default): Start all services
- `encryption`: Start encryption agents only
- `computation`: Start computation agents only
- `app`: Start MPC app only

**Usage**: 
```bash
./scripts/start-services.sh          # Start all
./scripts/start-services.sh encryption  # Start encryption agents only
```

### `stop-services.sh [service]`
Stops all or individual services.

**Usage**: `./scripts/stop-services.sh [service]`

### `check-services.sh`
Checks the status of all running services.

**Usage**: `./scripts/check-services.sh`

## Verification Scripts

### `verify-setup.sh`
Comprehensive setup verification.
- Checks repositories
- Verifies dependencies
- Validates configuration
- Checks MP-SPDZ installation

**Usage**: `./scripts/verify-setup.sh`

## Script Summary

| Script | Purpose |
|--------|---------|
| **Setup Scripts** | |
| `setup-services.sh` | Install dependencies and setup |
| `setup-local-solid.sh` | Set up local Solid IDP and Pod server |
| **Configuration Scripts** | |
| `configure-credentials.sh` | Configure encryption agent credentials |
| `configure-local-idp.sh` | Configure Libertas to use local IDP |
| `generate-preference.sh` | Generate preference document template |
| `generate-resource-desc.sh` | Generate resource description template |
| **Service Management** | |
| `start-services.sh` | Start services |
| `stop-services.sh` | Stop services |
| `check-services.sh` | Check service status |
| `start-solid-server.sh` | Start local Solid server |
| **Testing & Demo** | |
| `run-end-to-end-demo.sh` | Run complete end-to-end demo |
| `create-test-data.sh` | Create test data files |
| `upload-files-to-pod.sh` | Upload files to Solid Pod |
| `verify-setup.sh` | Verify complete setup |
| **Helper Scripts** | |
| `link-webid-guide.sh` | Guide for linking WebID |
| `setup-client-credentials.sh` | Guide for setting up client credentials |

## Quick Reference

```bash
# Complete setup
./setup.sh
./scripts/setup-services.sh
./scripts/configure-credentials.sh

# Local Solid server setup (optional)
./scripts/setup-local-solid.sh
./scripts/start-solid-server.sh
./scripts/configure-local-idp.sh test-user

# Run services
./scripts/start-services.sh
./scripts/check-services.sh

# Stop services
./scripts/stop-services.sh

# Verify everything
./scripts/verify-setup.sh
```

