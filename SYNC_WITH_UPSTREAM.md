# Syncing Your Fork with Upstream

This PR brings your fork up to date with the upstream repository (maester365/maester). However, depending on your needs, there are different ways to complete the sync.

## Current Status

-  **Upstream (maester365/maester)**: Latest commit `8acef589` (v1.3.96-preview)
- ✅ **This PR**: Merges all upstream changes into your fork
- ⚠️ **Your fork's main branch**: Currently at `3450c71` (2881 commits behind)

## Option 1: Merge This PR (Recommended for Most Users)

**What it does**: Brings all upstream changes into your fork while preserving your fork's commit history.

**How to do it**:
1. Review and approve this PR
2. Merge using "Create a merge commit" or "Squash and merge"
3. Your main branch will be functionally identical to upstream (same code), but with additional merge commits in the history

**Pros**: 
- Safe and straightforward
- Preserves any custom commits you may have had
- Can be done entirely through the GitHub web interface

**Cons**:
- Commit history won't be identical to upstream
- Will show a merge commit

## Option 2: Force Push to Match Upstream Exactly (Clean History)

**What it does**: Makes your fork's main branch identical to upstream, including commit history.

**How to do it**:
```bash
# Clone your repository
git clone https://github.com/SamErde/maester.git
cd maester

# Add upstream remote
git remote add upstream https://github.com/maester365/maester.git

# Fetch from upstream
git fetch upstream

# Checkout main and reset to upstream
git checkout main
git reset --hard upstream/main

# Force push to your fork (THIS WILL DISCARD ANY DIVERGENT COMMITS)
git push origin main --force
```

**Pros**:
- Clean, identical history to upstream
- True "rebase" as requested

**Cons**:
- Requires command line access
- Discards any unique commits in your fork
- Requires force push (potentially dangerous)

## Option 3: Use GitHub's Sync Fork Feature

**What it does**: GitHub provides a built-in feature to sync forks.

**How to do it**:
1. Go to https://github.com/SamErde/maester
2. Look for the "Sync fork" button (if available)
3. Click "Discard commits" if prompted

**Note**: This option is only available if GitHub detects your fork is behind.

## Recommendation

- **If you just want the latest code**: Merge this PR (Option 1)
- **If you want identical history to upstream**: Use Option 2 (force push)
- **If you never made custom changes to your fork**: Use Option 2 or 3

## What This PR Includes

This PR was automatically prepared with:
- Upstream remote already configured
- All changes from maester365/maester merged
- Working tree identical to upstream/main

Merging this PR will immediately bring your fork up to date with all the latest features and fixes from upstream.

## Verification

After syncing (regardless of method), you can verify with:
```bash
git fetch upstream
git log --oneline -5  # Should match upstream
```

Expected latest commit: `8acef589` (Merge pull request #1255)
