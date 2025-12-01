# Git Submodules Setup

The Libertas repository uses git submodules to manage dependencies. This document explains how to set up and work with submodules.

## What are Submodules?

Git submodules allow you to include other git repositories as subdirectories within your main repository. This is useful for:
- Keeping dependencies at specific versions
- Maintaining separate development workflows
- Managing external repositories

## Submodules in Libertas

The following repositories are included as submodules in `libertas-setup/`:

- **solid-mpc-app**: MPC App frontend
- **solid-mpc**: Agent Services (encryption and computation agents)
- **MP-SPDZ**: Secure Multi-Party Computation framework
- **community-solid-server**: Local Solid IDP and Pod server

## Initial Setup

### Clone with Submodules

When cloning the repository for the first time:

```bash
git clone --recursive https://github.com/OxfordHCC/libertas.git
cd libertas
```

The `--recursive` flag automatically initializes and clones all submodules.

### Initialize Existing Clone

If you've already cloned the repository without submodules:

```bash
cd libertas
git submodule update --init --recursive
```

This will:
1. Initialize the submodule configuration
2. Clone each submodule repository
3. Check out the commit specified in the main repository

## Working with Submodules

### Update Submodules

To update all submodules to their latest commits:

```bash
git submodule update --remote
```

To update a specific submodule:

```bash
git submodule update --remote libertas-setup/solid-mpc
```

### Pull Latest Changes

To pull the latest changes in the main repository and update submodules:

```bash
git pull
git submodule update --init --recursive
```

### Check Submodule Status

To see the status of all submodules:

```bash
git submodule status
```

This shows:
- The commit hash each submodule is on
- Whether there are uncommitted changes
- Whether the submodule is on a different commit than the main repo expects

### Making Changes in Submodules

If you need to make changes in a submodule:

1. Navigate to the submodule directory:
   ```bash
   cd libertas-setup/solid-mpc
   ```

2. Make your changes and commit them:
   ```bash
   git add .
   git commit -m "Your changes"
   git push
   ```

3. Return to the main repository and update the submodule reference:
   ```bash
   cd ../..
   git add libertas-setup/solid-mpc
   git commit -m "Update solid-mpc submodule"
   git push
   ```

## Troubleshooting

### Submodule Shows as Modified

If `git status` shows submodules as modified:

```bash
# Check what's different
git submodule status

# If you want to update to the latest commit
cd libertas-setup/solid-mpc
git checkout main  # or master, depending on the repo
git pull
cd ../..
git add libertas-setup/solid-mpc
git commit -m "Update submodule"
```

### Submodule is Empty

If a submodule directory exists but is empty:

```bash
git submodule update --init libertas-setup/solid-mpc
```

### Remove and Re-add Submodule

If you need to completely reset a submodule:

```bash
# Remove the submodule
git submodule deinit libertas-setup/solid-mpc
git rm libertas-setup/solid-mpc
rm -rf .git/modules/libertas-setup/solid-mpc

# Re-add it
git submodule add https://github.com/OxfordHCC/solid-mpc.git libertas-setup/solid-mpc
git submodule update --init --recursive
```

## Alternative: Regular Clones

If you prefer not to use submodules, you can clone repositories manually:

```bash
cd libertas-setup
git clone https://github.com/OxfordHCC/solid-mpc-app.git
git clone https://github.com/OxfordHCC/solid-mpc.git
git clone https://github.com/data61/MP-SPDZ.git MP-SPDZ
git clone https://github.com/CommunitySolidServer/CommunitySolidServer.git community-solid-server
```

**Note**: The setup script (`./setup.sh`) will handle cloning if submodules aren't configured.

## Best Practices

1. **Always use `--recursive` when cloning** to avoid missing submodules
2. **Commit submodule updates** when you update dependencies
3. **Document submodule versions** in your commit messages
4. **Test after updating submodules** to ensure compatibility

## Quick Reference

```bash
# Clone with submodules
git clone --recursive <repo-url>

# Initialize existing clone
git submodule update --init --recursive

# Update all submodules
git submodule update --remote

# Update specific submodule
git submodule update --remote libertas-setup/solid-mpc

# Check status
git submodule status

# Pull and update
git pull && git submodule update --init --recursive
```

---

For more information, see the [Git Submodules documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules).

