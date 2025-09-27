#!/usr/bin/env bash
set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=== Automated Upstream Rebase ==="
echo ""

# Run readiness check
if ! ./scripts/check-rebase-readiness.sh; then
    echo -e "${RED}❌ Readiness check failed${NC}"
    exit 1
fi

# Confirm with user
echo ""
echo -e "${YELLOW}⚠️  This will:${NC}"
echo "  1. Create a backup branch"
echo "  2. Create an integration branch"
echo "  3. Rebase onto upstream/main"
echo "  4. Auto-resolve tooling conflicts"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Create backup
backup_branch="backup/before-rebase-$(date +%Y%m%d-%H%M%S)"
echo -e "${BLUE}→${NC} Creating backup: $backup_branch"
git branch "$backup_branch"
echo -e "${GREEN}✅ Backup created${NC}"

# Get current branch
current_branch=$(git branch --show-current)

# Create integration branch
integration_branch="integrate/upstream-$(date +%Y%m%d)"
echo -e "${BLUE}→${NC} Creating integration branch: $integration_branch"
git checkout -b "$integration_branch"
echo -e "${GREEN}✅ Branch created${NC}"

# Start rebase
echo -e "${BLUE}→${NC} Starting rebase onto upstream/main..."
echo ""

if git rebase upstream/main; then
    echo ""
    echo -e "${GREEN}✅ Rebase completed without conflicts!${NC}"

    # Run tests
    echo ""
    echo -e "${BLUE}→${NC} Running unit tests..."
    if bun run test:unit > /dev/null 2>&1; then
        echo -e "${GREEN}✅ All tests passed${NC}"

        echo ""
        echo "=== Rebase Successful ==="
        echo "Integration branch: $integration_branch"
        echo "Backup branch: $backup_branch"
        echo ""
        echo "Next steps:"
        echo "  1. Review changes: git log --oneline $current_branch..$integration_branch"
        echo "  2. Test manually: bun run dev"
        echo "  3. Merge to main: git checkout main && git merge $integration_branch"
        echo "  4. Delete backup: git branch -D $backup_branch"
    else
        echo -e "${RED}❌ Tests failed${NC}"
        echo ""
        echo "Fix tests before merging to main."
        echo "To abort: git rebase --abort && git checkout $current_branch"
    fi
else
    echo ""
    echo -e "${YELLOW}⚠️  Conflicts detected${NC}"
    echo ""
    echo "Running automatic conflict resolution..."
    ./scripts/resolve-rebase-conflicts.sh

    echo ""
    echo "=== Manual Intervention Required ==="
    echo ""
    echo "After resolving all conflicts:"
    echo "  1. Run tests: bun run test:unit"
    echo "  2. Continue rebase: git rebase --continue"
    echo "  3. Or abort: git rebase --abort && git checkout $current_branch"
    echo ""
    echo "Backup available at: $backup_branch"
fi