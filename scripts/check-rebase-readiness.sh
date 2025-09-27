#!/usr/bin/env bash
set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== Rebase Readiness Check ==="
echo ""

# Check clean working tree
echo -n "Checking working tree cleanliness... "
if [[ -n $(git status --porcelain) ]]; then
    echo -e "${RED}❌ FAILED${NC}"
    echo "Working tree is not clean. Commit or stash changes first:"
    git status --short
    exit 1
fi
echo -e "${GREEN}✅ PASSED${NC}"

# Check we're on main or feature branch
current_branch=$(git branch --show-current)
echo -n "Checking current branch ($current_branch)... "
if [[ "$current_branch" != "main" ]] && [[ ! "$current_branch" =~ ^(feat|integrate)/ ]]; then
    echo -e "${YELLOW}⚠️  WARNING${NC}"
    echo "Not on main or feature branch. Consider switching branches."
else
    echo -e "${GREEN}✅ PASSED${NC}"
fi

# Check if upstream is configured
echo -n "Checking upstream remote... "
if ! git remote get-url upstream > /dev/null 2>&1; then
    echo -e "${RED}❌ FAILED${NC}"
    echo "Upstream remote not configured. Add with:"
    echo "  git remote add upstream git@github.com:campfirein/cipher.git"
    exit 1
fi
echo -e "${GREEN}✅ PASSED${NC}"

# Fetch latest upstream
echo -n "Fetching latest from upstream... "
if git fetch upstream > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASSED${NC}"
else
    echo -e "${RED}❌ FAILED${NC}"
    exit 1
fi

# Check commits ahead/behind
ahead=$(git rev-list --count HEAD..upstream/main)
behind=$(git rev-list --count upstream/main..HEAD)
echo "Status: $behind commits ahead of upstream, $ahead commits behind"

# Check if backup exists
backup_branch="backup/before-rebase-$(date +%Y%m%d)"
echo -n "Checking for backup branch... "
if git rev-parse --verify "$backup_branch" > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  EXISTS${NC}"
    echo "Backup branch '$backup_branch' already exists"
else
    echo -e "${GREEN}✅ READY${NC}"
    echo "Will create backup: $backup_branch"
fi

# Check if tests pass
echo -n "Running unit tests... "
if bun run test:unit > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASSED${NC}"
else
    echo -e "${RED}❌ FAILED${NC}"
    echo "Tests are failing on current branch. Fix before rebasing."
    exit 1
fi

# Summary
echo ""
echo "=== Summary ==="
echo -e "${GREEN}✅ Ready to rebase!${NC}"
echo ""
echo "Recommended next steps:"
echo "  1. Create backup: git branch $backup_branch"
echo "  2. Create integration branch: git checkout -b integrate/upstream-\$(date +%Y%m%d)"
echo "  3. Start rebase: git rebase upstream/main"
echo ""
echo "Or use the automated rebase script:"
echo "  ./scripts/rebase-from-upstream.sh"