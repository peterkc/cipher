#!/usr/bin/env bash
set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo "=== Compare Local Fork with Upstream ==="
echo ""

# Fetch latest
echo "Fetching latest from upstream..."
git fetch upstream > /dev/null 2>&1
echo -e "${GREEN}✅ Done${NC}"
echo ""

# Show commit divergence
ahead=$(git rev-list --count upstream/main..HEAD)
behind=$(git rev-list --count HEAD..upstream/main)

echo "=== Commit Status ==="
echo -e "${GREEN}Our unique commits:${NC} $ahead"
echo -e "${YELLOW}Upstream new commits:${NC} $behind"
echo ""

# Show our unique commits
if [[ $ahead -gt 0 ]]; then
    echo -e "${GREEN}=== Our Unique Commits ===${NC}"
    git log --oneline --no-merges upstream/main..HEAD | head -20
    echo ""
fi

# Show upstream new commits
if [[ $behind -gt 0 ]]; then
    echo -e "${YELLOW}=== New Upstream Commits ===${NC}"
    git log --oneline --no-merges HEAD..upstream/main | head -20
    echo ""
fi

# File differences
echo "=== File Differences ==="
echo ""

# Files only in our fork
echo -e "${BLUE}Files only in our fork:${NC}"
git diff --name-only --diff-filter=A HEAD upstream/main | grep -v "^$" || echo "  (none)"
echo ""

# Files deleted in our fork
echo -e "${RED}Files deleted in our fork:${NC}"
git diff --name-only --diff-filter=D HEAD upstream/main | grep -v "^$" || echo "  (none)"
echo ""

# Modified files
echo -e "${YELLOW}Modified files (ours vs upstream):${NC}"
git diff --name-only --diff-filter=M HEAD upstream/main | grep -v "^$" || echo "  (none)"
echo ""

# Key file comparison
echo "=== Key Configuration Files ==="
echo ""

KEY_FILES=(
    "package.json"
    "biome.json"
    "lefthook.yml"
    "justfile"
    "tsconfig.json"
    "vitest.config.ts"
)

for file in "${KEY_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        if git diff --quiet HEAD upstream/main -- "$file" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $file (identical)"
        else
            if git ls-tree -r upstream/main --name-only | grep -q "^$file$"; then
                echo -e "${YELLOW}≠${NC} $file (different)"
            else
                echo -e "${BLUE}+${NC} $file (only in our fork)"
            fi
        fi
    else
        if git ls-tree -r upstream/main --name-only | grep -q "^$file$"; then
            echo -e "${RED}−${NC} $file (deleted in our fork)"
        fi
    fi
done

echo ""
echo "=== Detailed Comparison Options ==="
echo ""
echo "View specific file differences:"
echo "  git diff HEAD..upstream/main -- <file>"
echo ""
echo "View all configuration differences:"
echo "  git diff HEAD..upstream/main -- package.json biome.json lefthook.yml"
echo ""
echo "View source code differences:"
echo "  git diff HEAD..upstream/main -- src/"
echo ""
echo "Interactive diff tool:"
echo "  git difftool HEAD..upstream/main"
echo ""

# Recent upstream activity
echo "=== Recent Upstream Activity ==="
echo ""
git log upstream/main --oneline --since="1 week ago" | head -10 || echo "No recent commits"
echo ""

# Check for potential conflicts
echo "=== Potential Conflict Analysis ==="
echo ""

# Find files modified both in our fork and upstream
conflict_candidates=$(comm -12 \
    <(git diff --name-only upstream/main...HEAD | sort) \
    <(git diff --name-only HEAD...upstream/main | sort) \
    2>/dev/null || true)

if [[ -n "$conflict_candidates" ]]; then
    echo -e "${YELLOW}⚠️  Files modified in both (potential conflicts):${NC}"
    echo "$conflict_candidates" | while read -r file; do
        echo "  - $file"
    done
    echo ""
    echo "Review these files carefully during rebase."
else
    echo -e "${GREEN}✅ No obvious conflict candidates${NC}"
fi
echo ""

# Dependencies comparison
echo "=== Dependency Comparison ==="
echo ""

if command -v jq > /dev/null 2>&1; then
    echo "New dependencies in upstream:"
    comm -13 \
        <(jq -r '.dependencies // {} | keys[]' package.json 2>/dev/null | sort) \
        <(git show upstream/main:package.json 2>/dev/null | jq -r '.dependencies // {} | keys[]' | sort) \
        2>/dev/null | head -10 || echo "  (none or unable to parse)"
    echo ""
fi

echo "=== Summary ==="
echo ""
if [[ $behind -eq 0 ]]; then
    echo -e "${GREEN}✅ Up to date with upstream${NC}"
elif [[ $behind -lt 10 ]]; then
    echo -e "${YELLOW}⚠️  Slightly behind upstream ($behind commits)${NC}"
    echo "Consider rebasing soon."
else
    echo -e "${RED}⚠️  Significantly behind upstream ($behind commits)${NC}"
    echo "Rebase recommended to avoid large conflicts."
fi