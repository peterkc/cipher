# Fork Management Automation Tools

**Parent**: [README.md](README.md)  
**Related**: [Workflow Strategy](workflow-strategy.md), [Integration Guidelines](integration-guidelines.md)

## Automation Scripts for Fork Management

### Core Automation Scripts

#### 1. Upstream Sync Assistant (`scripts/sync-upstream.sh`)

```bash
#!/bin/bash
# Automated upstream sync with intelligent conflict detection

set -e

echo "🔄 Cipher Fork Sync Assistant"
echo "Analyzing upstream changes and compatibility..."

# Fetch latest upstream
git fetch upstream

# Check current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $current_branch"

# Analyze upstream changes
echo "📊 Upstream changes since last sync:"
git log --oneline HEAD..upstream/main | head -10

# Conflict detection using merge-tree
echo "🔍 Analyzing potential conflicts..."
conflict_preview=$(git merge-tree $(git merge-base HEAD upstream/main) HEAD upstream/main 2>/dev/null | grep "<<<<<<< ")

if [ -n "$conflict_preview" ]; then
    echo "⚠️  Conflicts detected - manual resolution required"
    echo "Conflicts in:"
    git merge-tree $(git merge-base HEAD upstream/main) HEAD upstream/main | grep -E "^\+\+\+|^---" | sort -u
    echo ""
    echo "Run: git rebase upstream/main"
    echo "Then use conflict resolution workflow"
    exit 1
else
    echo "✅ Clean integration possible"
    read -p "Proceed with rebase? (y/N): " confirm
    
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        git rebase upstream/main
        echo "🚀 Upstream sync complete!"
        echo "Run: git push origin $current_branch --force-with-lease"
    else
        echo "Sync cancelled - run manually when ready"
    fi
fi
```

#### 2. Conflict Resolution Helper (`scripts/resolve-conflicts.sh`)

```bash
#!/bin/bash
# Interactive conflict resolution assistant for cipher fork

echo "🔧 Cipher Conflict Resolution Assistant"

# Find conflicted files
conflicted_files=$(git diff --name-only --diff-filter=U)

if [ -z "$conflicted_files" ]; then
    echo "✅ No conflicts to resolve"
    exit 0
fi

echo "📋 Conflicted files:"
echo "$conflicted_files"
echo ""

# Process each conflict systematically
for file in $conflicted_files; do
    echo "🔍 Resolving: $file"
    
    case $file in
        "package.json")
            echo "📦 Package.json conflict detected"
            echo "Priority: Preserve Bun + Lefthook + BiomeJS migration"
            echo "Strategy: Keep origin tooling, accept upstream version and dependencies"
            echo "⚡ Opening for manual resolution..."
            ;;
        "*.ts"|"*.js")
            echo "💻 Code conflict in TypeScript/JavaScript file"
            echo "Priority: Preserve architectural improvements and Bun compatibility"
            echo "Strategy: Evaluate upstream changes for compatibility"
            ;;
        "*.json"|"*.yaml"|"*.yml")
            echo "⚙️  Configuration file conflict"
            echo "Priority: Maintain modernization configuration"
            echo "Strategy: Preserve BiomeJS/Lefthook/Bun configs"
            ;;
        "docker/*"|"Dockerfile")
            echo "🐳 Docker infrastructure conflict"  
            echo "Priority: Keep enhanced Docker setup"
            echo "Strategy: Merge compatible upstream Docker improvements"
            ;;
        *)
            echo "📄 General file conflict"
            echo "Strategy: Case-by-case evaluation required"
            ;;
    esac
    
    echo ""
done

echo "🛠️  Resolution Commands:"
echo "git add <resolved-file>     # Mark conflict as resolved"
echo "git rebase --continue       # Continue rebase after resolution" 
echo "git rebase --abort          # Cancel if too complex"
echo ""
echo "🧪 Validation Commands:"
echo "bun run test                # Test after resolution"
echo "bun run build               # Verify build works"
echo "bunx lefthook run pre-commit # Test quality gates"
```

#### 3. Fork Health Monitor (`scripts/fork-health.sh`)

```bash
#!/bin/bash
# Monitor fork health and divergence metrics

echo "📊 Cipher Fork Health Report"
echo "================================"

# Basic divergence metrics
ahead_count=$(git rev-list --count HEAD ^upstream/main)
behind_count=$(git rev-list --count upstream/main ^HEAD)

echo "📈 Divergence Metrics:"
echo "  Commits ahead of upstream: $ahead_count"
echo "  Commits behind upstream: $behind_count"
echo ""

# Check for critical upstream changes
echo "🔍 Recent Upstream Activity:"
git fetch upstream >/dev/null 2>&1
git log --oneline upstream/main --since="1 week ago" | head -5
echo ""

# Validate current fork functionality
echo "🧪 Fork Functionality Check:"
echo "  Build status: $(bun run build >/dev/null 2>&1 && echo "✅ Pass" || echo "❌ Fail")"
echo "  Test status: $(bun run test:ci >/dev/null 2>&1 && echo "✅ Pass" || echo "❌ Fail")"  
echo "  Typecheck: $(bun run typecheck >/dev/null 2>&1 && echo "✅ Pass" || echo "⚠️  Issues")"
echo ""

# Check for dependency staleness
echo "📦 Dependency Health:"
outdated_deps=$(bun outdated --json 2>/dev/null | jq -r '.[] | select(.current != .latest) | .name' 2>/dev/null || echo "Unable to check")
if [ "$outdated_deps" != "Unable to check" ] && [ -n "$outdated_deps" ]; then
    echo "  Outdated dependencies detected:"
    echo "$outdated_deps" | sed 's/^/    /'
else
    echo "  Dependencies current or check unavailable"
fi
echo ""

# Integration recommendation
if [ $behind_count -gt 5 ]; then
    echo "🚨 Recommendation: Schedule upstream integration (>5 commits behind)"
elif [ $behind_count -gt 0 ]; then
    echo "💡 Suggestion: Consider upstream sync ($behind_count commits available)"
else
    echo "✅ Fork is current with upstream"
fi
```

### Automated GitHub Actions Integration

#### Upstream Monitor Workflow (`.github/workflows/upstream-monitor.yml`)

```yaml
name: Fork Upstream Monitor

on:
  schedule:
    - cron: '0 9 * * MON'  # Monday 9 AM UTC
  workflow_dispatch:

jobs:
  upstream-monitor:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout fork
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Add upstream remote
        run: |
          git remote add upstream https://github.com/campfirein/cipher.git
          git fetch upstream
          
      - name: Analyze upstream changes
        run: |
          echo "## Weekly Upstream Analysis" >> $GITHUB_STEP_SUMMARY
          echo "### New Commits" >> $GITHUB_STEP_SUMMARY  
          git log --oneline HEAD..upstream/main | head -10 >> $GITHUB_STEP_SUMMARY
          
          echo "### Divergence Status" >> $GITHUB_STEP_SUMMARY
          ahead=$(git rev-list --count HEAD ^upstream/main)
          behind=$(git rev-list --count upstream/main ^HEAD)
          echo "- Commits ahead: $ahead" >> $GITHUB_STEP_SUMMARY
          echo "- Commits behind: $behind" >> $GITHUB_STEP_SUMMARY
          
      - name: Check integration complexity
        run: |
          conflicts=$(git merge-tree $(git merge-base HEAD upstream/main) HEAD upstream/main | grep "<<<<<<< " | wc -l)
          if [ $conflicts -gt 0 ]; then
            echo "⚠️ Conflicts detected: $conflicts potential conflict sections"
            echo "Integration will require manual resolution"
          else
            echo "✅ Clean integration possible"
          fi
```

#### Fork Validation Workflow (`.github/workflows/fork-validation.yml`)

```yaml
name: Fork Quality Validation

on:
  push:
    branches: [ feat/bun, fork-main ]
  pull_request:
    branches: [ fork-main ]

jobs:
  validate-modernization:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Bun
        uses: oven-sh/setup-bun@v2
        with:
          bun-version: latest
          
      - name: Install dependencies
        run: bun install
        
      - name: Validate Bun ecosystem
        run: |
          # Verify Bun-specific functionality
          bun --version
          bun run typecheck
          bun scripts/copy-ui-dist.ts
          
      - name: Test Lefthook integration
        run: |
          bunx lefthook install
          bunx lefthook run pre-commit --all-files
          
      - name: BiomeJS validation
        run: |
          bunx @biomejs/biome check .
          bunx @biomejs/biome lint .
          
      - name: Full build validation
        run: |
          bun run build
          ls -la dist/
```

## Integration Automation Strategies

### Automated Conflict Prevention

#### Pre-Integration Compatibility Check
```bash
#!/bin/bash
# scripts/pre-integration-check.sh

echo "🔍 Pre-Integration Compatibility Analysis"

# Check if upstream changes affect core modernization files
affected_files=$(git diff --name-only HEAD..upstream/main)

echo "📁 Files affected by upstream changes:"
echo "$affected_files"

# Flag critical conflicts
critical_conflicts=false

echo $affected_files | grep -q "package.json" && {
    echo "⚠️  package.json changes detected - review dependency impacts"
    critical_conflicts=true
}

echo $affected_files | grep -q "tsconfig" && {
    echo "⚠️  TypeScript config changes - review Bun compatibility"
    critical_conflicts=true
}

echo $affected_files | grep -q -E "\.(yml|yaml)$" && {
    echo "⚠️  YAML config changes - review Lefthook/CI impacts"
    critical_conflicts=true
}

if $critical_conflicts; then
    echo ""
    echo "🛑 Critical conflicts possible - manual review recommended"
    echo "Run detailed analysis: git diff HEAD..upstream/main"
    exit 1
else
    echo ""
    echo "✅ Integration appears safe to proceed"
    exit 0
fi
```

### Selective Integration Tools

#### Cherry-Pick Assistant
```bash
#!/bin/bash
# scripts/selective-integration.sh

upstream_commit=$1
if [ -z "$upstream_commit" ]; then
    echo "Usage: $0 <upstream-commit-hash>"
    exit 1
fi

echo "🍒 Selective Integration Assistant"
echo "Analyzing commit: $upstream_commit"

# Show commit details
git show --stat $upstream_commit

echo ""
read -p "Integrate this commit? (y/N): " confirm

if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    # Create integration branch
    integration_branch="cherry-pick/$(git show --format=%f -s $upstream_commit)"
    git checkout -b "$integration_branch"
    
    # Attempt cherry-pick
    if git cherry-pick $upstream_commit; then
        echo "✅ Cherry-pick successful"
        echo "🧪 Running validation tests..."
        
        if bun run test:ci && bun run build; then
            echo "✅ Validation passed"
            echo "🚀 Ready to merge to main branch"
        else
            echo "❌ Validation failed - review changes"
        fi
    else
        echo "⚠️  Cherry-pick conflicts - manual resolution required"
    fi
else
    echo "Integration skipped"
fi
```

## Monitoring and Metrics

### Fork Divergence Tracking

#### Automated Metrics Collection
```bash
#!/bin/bash
# scripts/fork-metrics.sh

# Generate fork metrics for tracking
metrics_file="fork-metrics-$(date +%Y%m%d).json"

cat > $metrics_file << EOF
{
  "date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "commits_ahead": $(git rev-list --count HEAD ^upstream/main),
  "commits_behind": $(git rev-list --count upstream/main ^HEAD),
  "unique_files": $(git diff --name-only upstream/main...HEAD | wc -l),
  "lines_added": $(git diff --shortstat upstream/main...HEAD | grep -o '[0-9]* insertions' | grep -o '[0-9]*'),
  "lines_removed": $(git diff --shortstat upstream/main...HEAD | grep -o '[0-9]* deletions' | grep -o '[0-9]*'),
  "build_status": "$(bun run build >/dev/null 2>&1 && echo 'pass' || echo 'fail')",
  "test_status": "$(bun run test:ci >/dev/null 2>&1 && echo 'pass' || echo 'fail')"
}
EOF

echo "📊 Metrics saved to: $metrics_file"
cat $metrics_file | jq .
```

### Integration Success Tracking

#### Post-Integration Validation
```bash
#!/bin/bash  
# scripts/post-integration-validation.sh

echo "🧪 Post-Integration Validation Suite"

# Verify core modernization features still work
echo "1. Bun ecosystem validation..."
bun --version && echo "✅ Bun runtime" || echo "❌ Bun runtime"

echo "2. Lefthook functionality..."
bunx lefthook version >/dev/null 2>&1 && echo "✅ Lefthook" || echo "❌ Lefthook"

echo "3. BiomeJS integration..."  
bunx @biomejs/biome --version >/dev/null 2>&1 && echo "✅ BiomeJS" || echo "❌ BiomeJS"

echo "4. Build process validation..."
bun run build >/dev/null 2>&1 && echo "✅ Build" || echo "❌ Build"

echo "5. Test suite validation..."
bun run test:ci >/dev/null 2>&1 && echo "✅ Tests" || echo "❌ Tests"

echo "6. Quality gates validation..."
bunx lefthook run pre-commit --all-files >/dev/null 2>&1 && echo "✅ Quality gates" || echo "⚠️  Quality issues"

echo ""
echo "🎯 Integration Quality Score:"
passed=0
total=6

# Count successes (simplified for demo)
[[ $(bun --version 2>/dev/null) ]] && ((passed++))
[[ $(bunx lefthook version 2>/dev/null) ]] && ((passed++))
[[ $(bunx @biomejs/biome --version 2>/dev/null) ]] && ((passed++))
bun run build >/dev/null 2>&1 && ((passed++))
bun run test:ci >/dev/null 2>&1 && ((passed++))  
bunx lefthook run pre-commit --all-files >/dev/null 2>&1 && ((passed++))

score=$(( passed * 100 / total ))
echo "Score: $score% ($passed/$total checks passed)"

if [ $score -ge 80 ]; then
    echo "✅ Integration successful - fork health maintained"
elif [ $score -ge 60 ]; then
    echo "⚠️  Integration partial - some issues need attention"
else
    echo "❌ Integration problematic - consider rollback"
    exit 1
fi
```

## GitHub Integration Tools

### GitHub CLI Automation

#### Upstream PR Monitoring
```bash
#!/bin/bash
# scripts/monitor-upstream-prs.sh

echo "👀 Monitoring Upstream PRs for Integration Opportunities"

# List recent merged PRs
echo "📥 Recently merged PRs:"
gh pr list --repo campfirein/cipher --state merged --limit 10 --json number,title,mergedAt,labels

echo ""
echo "🔍 Looking for relevant changes..."

# Filter PRs by relevance to your work
relevant_labels=("enhancement" "bug" "security" "dependencies")

for label in "${relevant_labels[@]}"; do
    echo "🏷️  PRs with '$label' label:"
    gh pr list --repo campfirein/cipher --state merged --label "$label" --limit 5 --json number,title,mergedAt
done

echo ""
echo "💡 Integration Recommendations:"
echo "1. Review security-labeled PRs for immediate integration"
echo "2. Assess enhancement PRs for compatibility with Bun ecosystem"
echo "3. Evaluate bug fixes for relevance to your use cases"
```

#### Fork Comparison Dashboard
```bash
#!/bin/bash
# scripts/fork-comparison.sh

echo "🔄 Fork vs Upstream Comparison Dashboard"
echo "========================================"

# High-level stats
echo "📊 Repository Statistics:"
echo "Fork commits: $(git rev-list --count HEAD)"
echo "Upstream commits: $(git rev-list --count upstream/main)"  
echo "Unique commits: $(git rev-list --count HEAD ^upstream/main)"
echo "Behind upstream: $(git rev-list --count upstream/main ^HEAD)"
echo ""

# File-level changes
echo "📁 File Modification Summary:"
echo "Modified files: $(git diff --name-only upstream/main...HEAD | wc -l)"
echo "Added files: $(git diff --name-status upstream/main...HEAD | grep '^A' | wc -l)"
echo "Deleted files: $(git diff --name-status upstream/main...HEAD | grep '^D' | wc -l)"
echo ""

# Key architectural differences
echo "🏗️  Architectural Differences:"
echo "Package manager: $(grep -q '"bun"' package.json && echo "Bun" || echo "npm/pnpm")"
echo "Git hooks: $([ -f lefthook.yml ] && echo "Lefthook" || echo "Husky/other")"
echo "Linting: $(grep -q '@biomejs/biome' package.json && echo "BiomeJS" || echo "ESLint")"
echo "Build tool: $(grep -q 'bunup' package.json && echo "Bunup" || echo "tsup/other")"
```

## Tool Installation and Setup

### Development Environment Setup
```bash
#!/bin/bash
# scripts/setup-fork-tools.sh

echo "🛠️  Setting up Fork Management Tools"

# Install GitHub CLI if not present
if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    # Platform-specific installation
    case "$(uname)" in
        "Darwin") brew install gh ;;
        "Linux") 
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update && sudo apt install gh
            ;;
    esac
fi

# Setup git aliases for fork management
git config alias.sync-upstream '!./scripts/sync-upstream.sh'
git config alias.resolve-conflicts '!./scripts/resolve-conflicts.sh'  
git config alias.fork-health '!./scripts/fork-health.sh'

# Configure enhanced conflict resolution
git config merge.conflictStyle diff3
git config rebase.autoStash true
git config rebase.autoSquash true

# Setup push safety
git config push.default simple
git config push.followTags true

echo "✅ Fork management tools configured"
echo "Available commands:"
echo "  git sync-upstream       # Intelligent upstream sync"
echo "  git resolve-conflicts   # Conflict resolution assistant"  
echo "  git fork-health        # Fork status dashboard"
```

This automation suite provides comprehensive tooling for efficient, safe fork management while preserving your architectural innovations and enabling strategic upstream value adoption.

`★ Automation Insight ─────────────────────────────────`
• Automated conflict detection prevents integration surprises and reduces resolution time
• Health monitoring provides objective metrics for fork maintenance decision-making  
• GitHub integration enables proactive upstream change assessment and strategic planning
`───────────────────────────────────────────────────────`