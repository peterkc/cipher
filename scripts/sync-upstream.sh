#!/bin/bash
# Automated upstream sync with intelligent conflict detection
# Part of cipher fork management strategy

set -e

echo "🔄 Cipher Fork Sync Assistant"
echo "Analyzing upstream changes and compatibility..."

# Fetch latest upstream
echo "📡 Fetching upstream changes..."
git fetch upstream

# Check current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $current_branch"

# Analyze upstream changes
echo ""
echo "📊 Upstream changes since last sync:"
upstream_commits=$(git log --oneline HEAD..upstream/main | wc -l)
echo "Total upstream commits: $upstream_commits"

if [ $upstream_commits -eq 0 ]; then
    echo "✅ Fork is current with upstream"
    exit 0
fi

echo "Recent commits:"
git log --oneline HEAD..upstream/main | head -10

# Conflict detection using merge-tree
echo ""
echo "🔍 Analyzing potential conflicts..."
base_commit=$(git merge-base HEAD upstream/main)
conflict_preview=$(git merge-tree $base_commit HEAD upstream/main 2>/dev/null)

if echo "$conflict_preview" | grep -q "<<<<<<< "; then
    echo "⚠️  Conflicts detected - manual resolution required"
    echo ""
    echo "Files with conflicts:"
    echo "$conflict_preview" | grep -E "^\+\+\+|^---" | sed 's/^[+\-]*[ab]\///' | sort -u | grep -v /dev/null
    echo ""
    echo "🛠️  Manual resolution workflow:"
    echo "1. git rebase upstream/main"
    echo "2. Resolve conflicts using: ./scripts/resolve-conflicts.sh"
    echo "3. git rebase --continue"
    echo "4. ./scripts/post-integration-validation.sh"
    echo "5. git push origin $current_branch --force-with-lease"
    exit 1
else
    echo "✅ Clean integration possible"
    echo ""
    read -p "Proceed with automatic rebase? (y/N): " confirm
    
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        echo "🚀 Starting rebase..."
        git rebase upstream/main
        
        echo ""
        echo "✅ Upstream sync complete!"
        echo "📋 Next steps:"
        echo "1. Run validation: ./scripts/post-integration-validation.sh"
        echo "2. Push changes: git push origin $current_branch --force-with-lease"
        echo "3. Update fork documentation if needed"
    else
        echo "Sync cancelled - run manually when ready"
        echo "Use: git rebase upstream/main"
    fi
fi