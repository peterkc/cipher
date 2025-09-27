#!/usr/bin/env bash
set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=== Automatic Conflict Resolution Helper ==="
echo ""

# Check if we're in a rebase
if ! git status | grep -q "rebase in progress"; then
    echo -e "${RED}❌ Not in a rebase${NC}"
    echo "This script should be run during a rebase when conflicts occur."
    exit 1
fi

# Files to always keep our version (ours)
KEEP_OURS=(
    "package.json"
    "bun.lock"
    "biome.json"
    "lefthook.yml"
    "justfile"
    "bunfig.toml"
    ".gitignore"
)

# Files to always take upstream version (theirs)
TAKE_THEIRS=(
    # Add any files that should always come from upstream
)

echo "Auto-resolving tooling configuration conflicts..."
echo ""

resolved_count=0
manual_count=0

# Auto-keep our tooling configs
for file in "${KEEP_OURS[@]}"; do
    if git status --porcelain | grep -q "^UU.*$file\|^DU.*$file\|^UD.*$file"; then
        echo -e "${BLUE}→${NC} Keeping our version: $file"
        if git show :2:"$file" > /dev/null 2>&1; then
            git checkout --ours "$file" 2>/dev/null || echo "  (file doesn't exist in our version)"
            git add "$file" 2>/dev/null || true
            ((resolved_count++))
        else
            echo "  ${YELLOW}⚠️  File deleted in our version, skipping${NC}"
        fi
    fi
done

# Auto-take upstream versions
for file in "${TAKE_THEIRS[@]}"; do
    if git status --porcelain | grep -q "^UU.*$file\|^DU.*$file\|^UD.*$file"; then
        echo -e "${BLUE}→${NC} Taking upstream version: $file"
        if git show :3:"$file" > /dev/null 2>&1; then
            git checkout --theirs "$file" 2>/dev/null || echo "  (file doesn't exist in upstream)"
            git add "$file" 2>/dev/null || true
            ((resolved_count++))
        else
            echo "  ${YELLOW}⚠️  File deleted in upstream, skipping${NC}"
        fi
    fi
done

echo ""
echo "=== Resolution Summary ==="
echo -e "${GREEN}✅ Auto-resolved: $resolved_count files${NC}"

# Check remaining conflicts
remaining=$(git diff --name-only --diff-filter=U | wc -l)
if [[ $remaining -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  Manual resolution needed: $remaining files${NC}"
    echo ""
    echo "Files requiring manual resolution:"
    git diff --name-only --diff-filter=U | while read -r file; do
        echo "  - $file"
    done
    echo ""
    echo "For each file, choose:"
    echo "  git checkout --ours <file>    # Keep our version"
    echo "  git checkout --theirs <file>  # Take upstream version"
    echo "  vim <file>                    # Manually merge both"
    echo ""
    echo "After resolving, run:"
    echo "  git add <resolved-files>"
    echo "  git rebase --continue"
else
    echo -e "${GREEN}✅ All conflicts resolved!${NC}"
    echo ""
    echo "Run tests before continuing:"
    echo "  bun run test:unit"
    echo ""
    echo "If tests pass, continue rebase:"
    echo "  git rebase --continue"
fi