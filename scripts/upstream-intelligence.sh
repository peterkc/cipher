#!/bin/bash
# Intelligent upstream change analysis for post-independence planning
# Uses pre-externalization tracking branch as baseline for change evaluation

set -e

# Configuration
BASELINE_BRANCH="tracking/pre-externalization"  # Your proposed tracking branch
ANALYSIS_SINCE=${1:-"2 weeks ago"}

echo "🧠 Upstream Intelligence Analysis"
echo "================================="
echo "Baseline: $BASELINE_BRANCH"
echo "Analyzing changes since: $ANALYSIS_SINCE"
echo "Generated: $(date)"
echo ""

# Ensure we have the latest data
git fetch upstream >/dev/null 2>&1
git fetch origin >/dev/null 2>&1

# Check if baseline branch exists
if ! git rev-parse --verify origin/$BASELINE_BRANCH >/dev/null 2>&1; then
    echo "⚠️  Baseline branch 'origin/$BASELINE_BRANCH' not found"
    echo "Create it with: git checkout feat/bun && git checkout -b $BASELINE_BRANCH && git push origin $BASELINE_BRANCH"
    exit 1
fi

# Get baseline commit for comparison
baseline_commit=$(git rev-parse origin/$BASELINE_BRANCH)
echo "🎯 Baseline commit: $baseline_commit"

# Analyze upstream changes since baseline
upstream_changes=$(git log --oneline $baseline_commit..upstream/main --since="$ANALYSIS_SINCE")

if [ -z "$upstream_changes" ]; then
    echo "✅ No upstream changes since baseline in specified timeframe"
    exit 0
fi

total_changes=$(echo "$upstream_changes" | wc -l)
echo "📊 Total upstream changes: $total_changes"
echo ""

# Package-relevance analysis based on future NPM structure
echo "📦 Package Relevance Analysis:"
echo "Categorizing changes by future @peterkc/cipher-* package structure"
echo ""

# Define package path mappings for analysis
analyze_package_relevance() {
    local package_name=$1
    local path_pattern=$2
    local description=$3
    
    echo "🔍 **$package_name**"
    echo "   Scope: $description"
    echo "   Paths: $path_pattern"
    
    # Find changes affecting this package area
    relevant_commits=$(git log --oneline $baseline_commit..upstream/main --since="$ANALYSIS_SINCE" -- $path_pattern 2>/dev/null || echo "")
    
    if [ -n "$relevant_commits" ]; then
        change_count=$(echo "$relevant_commits" | wc -l)
        echo "   📈 Changes: $change_count commits"
        echo "   📋 Recent commits:"
        echo "$relevant_commits" | head -3 | sed 's/^/      /'
        
        # Analyze change types
        security_changes=$(echo "$relevant_commits" | grep -iE "security|fix|vulnerability|patch" | wc -l)
        feature_changes=$(echo "$relevant_commits" | grep -iE "feat|add|new|enhance" | wc -l)
        refactor_changes=$(echo "$relevant_commits" | grep -iE "refactor|improve|optimize" | wc -l)
        
        echo "   🏷️  Change types: Security($security_changes) Features($feature_changes) Refactoring($refactor_changes)"
        
        # Integration recommendations
        if [ $security_changes -gt 0 ]; then
            echo "   🚨 HIGH PRIORITY: Security changes detected - review for cherry-picking"
        elif [ $feature_changes -gt 0 ]; then
            echo "   💡 MEDIUM PRIORITY: New features available - assess compatibility"
        elif [ $refactor_changes -gt 0 ]; then
            echo "   🔧 LOW PRIORITY: Refactoring changes - evaluate architectural benefits"
        else
            echo "   📝 INFORMATIONAL: General changes - monitor for patterns"
        fi
    else
        echo "   ✅ No changes affecting this package area"
    fi
    echo ""
}

# Analyze each future package area
analyze_package_relevance "@peterkc/cipher-core" "src/core/{agent,memory,events}" "Core AI agent framework and memory management"
analyze_package_relevance "@peterkc/cipher-brain" "src/core/brain" "LLM integration, embeddings, and AI tools"  
analyze_package_relevance "@peterkc/cipher-storage" "src/core/{storage,vector_storage,knowledge_graph}" "Data persistence and vector storage"
analyze_package_relevance "@peterkc/cipher-mcp" "src/core/mcp" "Model Context Protocol integration"
analyze_package_relevance "@peterkc/cipher-ui" "src/app/ui" "User interface and components"

# Overall integration assessment
echo "🎯 Integration Assessment Summary:"

security_total=$(git log --oneline $baseline_commit..upstream/main --since="$ANALYSIS_SINCE" | grep -iE "security|fix|vulnerability|patch" | wc -l)
feature_total=$(git log --oneline $baseline_commit..upstream/main --since="$ANALYSIS_SINCE" | grep -iE "feat|add|new|enhance" | wc -l)
deps_total=$(git log --oneline $baseline_commit..upstream/main --since="$ANALYSIS_SINCE" | grep -iE "dep|package|npm|yarn" | wc -l)

echo "   🚨 Security changes: $security_total (HIGH priority for cherry-picking)"
echo "   ✨ Feature changes: $feature_total (MEDIUM priority for evaluation)"  
echo "   📦 Dependency changes: $deps_total (LOW priority post-Bun migration)"

# Integration complexity assessment
files_changed=$(git diff --name-only $baseline_commit..upstream/main | wc -l)
lines_changed=$(git diff --stat $baseline_commit..upstream/main | tail -1 | grep -o '[0-9]* insertions\|[0-9]* deletions' | grep -o '[0-9]*' | paste -sd+ | bc 2>/dev/null || echo "0")

echo ""
echo "📊 Integration Complexity Assessment:"
echo "   Files affected: $files_changed"
echo "   Total line changes: ~$lines_changed"

if [ $files_changed -gt 100 ] || [ $lines_changed -gt 5000 ]; then
    echo "   🔴 HIGH COMPLEXITY: Major integration effort required"
    echo "   💡 Recommendation: Selective cherry-picking of critical changes only"
elif [ $files_changed -gt 50 ] || [ $lines_changed -gt 1000 ]; then
    echo "   🟡 MEDIUM COMPLEXITY: Moderate integration effort"  
    echo "   💡 Recommendation: Staged integration with thorough testing"
else
    echo "   🟢 LOW COMPLEXITY: Manageable integration"
    echo "   💡 Recommendation: Standard integration workflow applicable"
fi

echo ""
echo "🎯 Strategic Recommendations:"

if [ $security_total -gt 0 ]; then
    echo "   1. IMMEDIATE: Review security changes for cherry-picking"
    echo "      Command: git log --grep='security\\|fix\\|vulnerability' $baseline_commit..upstream/main"
fi

if [ $feature_total -gt 2 ]; then
    echo "   2. PLANNED: Significant feature development upstream"
    echo "      Command: git log --grep='feat\\|add\\|new' $baseline_commit..upstream/main"
fi

echo "   3. STRATEGIC: Monitor for architectural patterns useful for independent packages"
echo "   4. TIMING: Consider independence transition timing based on integration complexity"

echo ""
echo "🔗 Next Steps:"
echo "   ./scripts/cherry-pick-analysis.sh <commit-hash>  # Analyze specific commit for integration"
echo "   ./scripts/package-impact-analysis.sh            # Assess impact on package extraction plans"
echo "   git log --graph $baseline_commit..upstream/main  # Visualize upstream evolution"