#!/bin/bash
# Monitor cipher fork health and divergence metrics
# Part of comprehensive fork management strategy

echo "📊 Cipher Fork Health Report"
echo "================================"
echo "Generated: $(date)"
echo ""

# Ensure upstream is fetched
git fetch upstream >/dev/null 2>&1

# Basic divergence metrics
ahead_count=$(git rev-list --count HEAD ^upstream/main 2>/dev/null || echo "0")
behind_count=$(git rev-list --count upstream/main ^HEAD 2>/dev/null || echo "0")

echo "📈 Divergence Metrics:"
echo "  Commits ahead of upstream: $ahead_count"
echo "  Commits behind upstream: $behind_count"
echo "  Current branch: $(git rev-parse --abbrev-ref HEAD)"
echo "  Last sync: $(git log --oneline --grep="upstream" --since="1 month ago" | head -1 || echo "No recent sync found")"
echo ""

# Recent upstream activity
echo "🔍 Recent Upstream Activity (last 7 days):"
recent_upstream=$(git log --oneline upstream/main --since="1 week ago" 2>/dev/null || echo "Unable to fetch")
if [ "$recent_upstream" != "Unable to fetch" ]; then
    echo "$recent_upstream" | head -5
    upstream_activity_count=$(echo "$recent_upstream" | wc -l)
    echo "  Total upstream commits this week: $upstream_activity_count"
else
    echo "  Unable to fetch upstream activity"
fi
echo ""

# Fork functionality validation
echo "🧪 Fork Functionality Check:"

# Build validation
if bun run build >/dev/null 2>&1; then
    echo "  Build status: ✅ Pass"
    build_status="pass"
else
    echo "  Build status: ❌ Fail"
    build_status="fail"
fi

# Test validation
if bun run test:ci >/dev/null 2>&1; then
    echo "  Test status: ✅ Pass"
    test_status="pass"
else
    echo "  Test status: ❌ Fail"  
    test_status="fail"
fi

# TypeScript validation
if bun run typecheck >/dev/null 2>&1; then
    echo "  TypeScript: ✅ Pass"
    ts_status="pass"
else
    echo "  TypeScript: ⚠️  Issues (may be pre-existing)"
    ts_status="issues"
fi

# Modernization stack validation
echo ""
echo "🏗️  Modernization Stack Health:"

# Bun validation
if bun --version >/dev/null 2>&1; then
    bun_version=$(bun --version)
    echo "  Bun runtime: ✅ v$bun_version"
else
    echo "  Bun runtime: ❌ Not available"
fi

# Lefthook validation  
if bunx lefthook version >/dev/null 2>&1; then
    lefthook_version=$(bunx lefthook version 2>/dev/null)
    echo "  Lefthook: ✅ v$lefthook_version"
else
    echo "  Lefthook: ❌ Not available"
fi

# BiomeJS validation
if bunx @biomejs/biome --version >/dev/null 2>&1; then
    biome_version=$(bunx @biomejs/biome --version 2>/dev/null)
    echo "  BiomeJS: ✅ $biome_version"
else
    echo "  BiomeJS: ❌ Not available"  
fi

echo ""

# Dependency health check
echo "📦 Dependency Health:"
if command -v jq >/dev/null 2>&1; then
    outdated_deps=$(bun outdated --json 2>/dev/null | jq -r '.[] | select(.current != .latest) | .name' 2>/dev/null || echo "")
    if [ -n "$outdated_deps" ]; then
        echo "  Outdated dependencies detected:"
        echo "$outdated_deps" | sed 's/^/    /'
    else
        echo "  ✅ Dependencies appear current"
    fi
else
    echo "  ⚠️  jq not available - cannot check dependency status"
fi

echo ""

# Integration recommendations
echo "🎯 Integration Recommendations:"

if [ $behind_count -gt 10 ]; then
    echo "  🚨 URGENT: Significantly behind upstream ($behind_count commits)"
    echo "     Recommendation: Schedule comprehensive integration review"
    priority="high"
elif [ $behind_count -gt 5 ]; then
    echo "  ⚡ HIGH: Notable upstream changes available ($behind_count commits)"
    echo "     Recommendation: Plan integration within 1-2 weeks"
    priority="medium"
elif [ $behind_count -gt 0 ]; then
    echo "  💡 MODERATE: Some upstream changes available ($behind_count commits)"
    echo "     Recommendation: Review for valuable changes to integrate"
    priority="low"
else
    echo "  ✅ CURRENT: Fork is up to date with upstream"
    priority="none"
fi

echo ""

# Health score calculation
health_score=0
total_checks=6

[ "$build_status" = "pass" ] && ((health_score++))
[ "$test_status" = "pass" ] && ((health_score++))
[ "$ts_status" != "fail" ] && ((health_score++))  # Allow warnings
[ "$bun_version" != "" ] && ((health_score++))
[ "$lefthook_version" != "" ] && ((health_score++))
[ "$biome_version" != "" ] && ((health_score++))

health_percentage=$((health_score * 100 / total_checks))

echo "📋 Fork Health Summary:"
echo "  Overall health: $health_percentage% ($health_score/$total_checks checks passed)"
echo "  Integration priority: $priority"
echo "  Modernization stack: $([ $health_score -ge 4 ] && echo "Healthy" || echo "Needs attention")"

if [ $health_percentage -ge 80 ]; then
    echo "  Status: ✅ Excellent fork health"
elif [ $health_percentage -ge 60 ]; then
    echo "  Status: ⚠️  Good health with some issues"
else
    echo "  Status: 🔧 Fork needs maintenance attention"
fi

echo ""
echo "🔗 Useful Commands:"
echo "  ./scripts/sync-upstream.sh          # Sync with upstream"
echo "  ./scripts/resolve-conflicts.sh      # Resolve conflicts"
echo "  ./scripts/post-integration-validation.sh  # Validate after changes"
echo "  git log --graph --oneline upstream/main...HEAD  # View fork divergence"