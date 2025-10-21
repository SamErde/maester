#!/bin/bash

# This script syncs the main branch of your fork with the upstream repository
# by discarding divergent commits and resetting to match upstream exactly.
#
# WARNING: This will discard any commits in your fork's main branch that
# differ from the upstream repository.
#
# Usage: ./sync-with-upstream.sh

set -e  # Exit on error

echo "========================================"
echo "Fork Synchronization Script"
echo "========================================"
echo ""
echo "This will sync your fork's main branch with upstream/main"
echo "by resetting it to match maester365/maester exactly."
echo ""
echo "WARNING: This will DISCARD any divergent commits in your fork."
echo ""
read -p "Do you want to continue? (yes/no): " response

if [ "$response" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Step 1: Ensuring upstream remote is configured..."
if git remote | grep -q "^upstream$"; then
    echo "✓ Upstream remote already exists"
else
    echo "Adding upstream remote..."
    git remote add upstream https://github.com/maester365/maester.git
    echo "✓ Upstream remote added"
fi

echo ""
echo "Step 2: Fetching latest changes from upstream..."
git fetch upstream
echo "✓ Fetched from upstream"

echo ""
echo "Step 3: Checking out main branch..."
git checkout main
echo "✓ On main branch"

echo ""
echo "Step 4: Resetting main to match upstream/main..."
git reset --hard upstream/main
echo "✓ Main branch reset to upstream/main"

echo ""
echo "Current main branch commit:"
git log --oneline -1

echo ""
echo "Step 5: Force pushing to origin..."
echo "This step will push the changes to GitHub..."
read -p "Ready to force push? (yes/no): " push_response

if [ "$push_response" != "yes" ]; then
    echo ""
    echo "Sync stopped before pushing."
    echo "Your local main branch has been reset to upstream/main,"
    echo "but changes have not been pushed to GitHub."
    echo ""
    echo "To complete the sync later, run: git push origin main --force"
    exit 0
fi

git push origin main --force
echo "✓ Force pushed to origin/main"

echo ""
echo "========================================"
echo "✓ Sync complete!"
echo "========================================"
echo ""
echo "Your fork's main branch now matches upstream exactly."
echo "Latest commit: $(git log --oneline -1)"
