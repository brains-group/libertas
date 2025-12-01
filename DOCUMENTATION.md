# Libertas Documentation Index

This document provides an overview of all available documentation for the Libertas framework.

## Getting Started

- **[README.md](./README.md)** - Main repository overview and quick start
- **[SETUP.md](./SETUP.md)** - Complete setup and run guide
- **[SUBMODULES.md](./SUBMODULES.md)** - Git submodules setup and management

## Local Development

- **[LOCAL_SOLID_SETUP.md](./LOCAL_SOLID_SETUP.md)** - Setting up local Solid IDP and Pod server
- **[END_TO_END_DEMO.md](./END_TO_END_DEMO.md)** - Complete end-to-end demo guide
- **[UPLOAD_FILES_GUIDE.md](./UPLOAD_FILES_GUIDE.md)** - How to upload files to Solid Pods

## Authentication & Configuration

- **[SOLID_LOGIN_ENDPOINTS.md](./SOLID_LOGIN_ENDPOINTS.md)** - Community Solid Server authentication endpoints
- **[COMMUNITY_SOLID_AUTH.md](./COMMUNITY_SOLID_AUTH.md)** - Authentication guide for Community Solid Server

## Scripts

- **[scripts/README.md](./scripts/README.md)** - Documentation for all helper scripts

## Specification

- **[spec/index.html](./spec/index.html)** - Libertas protocol specification
  - If not rendered, try [this link](https://oxfordhcc.github.io/libertas/spec/index.html)

## Quick Reference

### Setup
1. Clone with submodules: `git clone --recursive <repo-url>`
2. Run setup: `./setup.sh && ./scripts/setup-services.sh`
3. Configure: `./scripts/configure-credentials.sh`
4. Start: `./scripts/start-services.sh`

### Local Solid Server
1. Setup: `./scripts/setup-local-solid.sh`
2. Start: `./scripts/start-solid-server.sh`
3. Configure: `./scripts/configure-local-idp.sh`

### Running Demo
1. Upload files: `./scripts/upload-files-to-pod.sh`
2. Run demo: `./scripts/run-end-to-end-demo.sh`
3. Access: http://localhost:5173

---

For questions or issues, please refer to the individual documentation files or open an issue on GitHub.

