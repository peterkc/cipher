# Upstream Rebase Workflow

## Visual Decision Tree

```
┌─────────────────────────────────┐
│   Want to sync with upstream?   │
└───────────┬─────────────────────┘
            │
            ▼
┌─────────────────────────────────┐
│ ./scripts/compare-with-upstream │  ← Check status first
└───────────┬─────────────────────┘
            │
            ▼
       ┌────┴────┐
       │ Behind? │
       └────┬────┘
            │
    ┌───────┴───────┐
    │ < 10 commits  │ > 10 commits
    ▼               ▼
┌─────────┐    ┌──────────────┐
│ Simple  │    │ Review first │
│ rebase  │    │ Large change │
└────┬────┘    └──────┬───────┘
     │                │
     │                ▼
     │     ┌──────────────────────┐
     │     │ Cherry-pick specific │
     │     │ features individually│
     │     └──────────────────────┘
     │
     ▼
┌────────────────────────────────────┐
│ ./scripts/check-rebase-readiness   │  ← Validate before starting
└────────────┬───────────────────────┘
             │
        ┌────┴────┐
        │ Ready?  │
        └────┬────┘
             │
      ┌──────┴──────┐
      │ Yes         │ No → Fix issues first
      ▼
┌─────────────────────────────────────┐
│ ./scripts/rebase-from-upstream      │  ← Automated workflow
└─────────────┬───────────────────────┘
              │
         ┌────┴────┐
         │Conflicts?│
         └────┬────┘
              │
      ┌───────┴────────┐
      │ Auto-resolved  │ Manual needed
      ▼                ▼
┌──────────┐    ┌──────────────────────────┐
│ Tests    │    │ ./scripts/resolve-rebase  │
│          │    │           +               │
│          │    │   Manual resolution       │
└────┬─────┘    └─────────┬────────────────┘
     │                    │
     │                    ▼
     │            ┌───────────────┐
     │            │ git add files │
     │            │ git rebase    │
     │            │ --continue    │
     │            └───────┬───────┘
     │                    │
     └────────────────────┘
              │
              ▼
       ┌─────────────┐
       │ Tests pass? │
       └──────┬──────┘
              │
        ┌─────┴─────┐
        │ Yes       │ No → Debug & fix
        ▼
  ┌──────────────┐
  │ Review logs  │
  │ git log      │
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐
  │ Merge to     │
  │ main         │
  └──────────────┘
```

## Workflow Examples

### Example 1: Regular Monthly Sync

```bash
# 1. Check status
./scripts/compare-with-upstream.sh

# Output shows: 15 commits behind

# 2. Check readiness
./scripts/check-rebase-readiness.sh

# Output: ✅ Ready to rebase

# 3. Run automated rebase
./scripts/rebase-from-upstream.sh

# Automated workflow:
# - Creates backup/before-rebase-20250926-120000
# - Creates integrate/upstream-20250926
# - Rebases onto upstream/main
# - Auto-resolves config conflicts
# - Runs tests

# 4. If successful, merge
git checkout main
git merge integrate/upstream-20250926
git push origin main
```

### Example 2: Cherry-Pick Specific Feature

```bash
# 1. Find the feature commits
git log --oneline upstream/main --grep="DeepSeek"

# Output: a1b2c3d feat: add DeepSeek LLM provider

# 2. Cherry-pick
git checkout -b feat/deepseek-integration
git cherry-pick a1b2c3d

# 3. Test
bun run test src/core/llm/__test__/*

# 4. Merge if successful
git checkout main
git merge feat/deepseek-integration
```

### Example 3: Conflict Resolution

```bash
# During rebase, conflicts occur:
# <<<<<<< HEAD
# Bun configuration
# =======
# pnpm configuration
# >>>>>>> upstream

# Run conflict helper
./scripts/resolve-rebase-conflicts.sh

# Auto-resolves tooling configs
# Manual review needed for source code

# For source conflicts:
git diff --ours --theirs src/path/file.ts

# Choose strategy
git checkout --ours src/path/file.ts  # Keep ours
# OR
git checkout --theirs src/path/file.ts  # Take upstream
# OR
vim src/path/file.ts  # Manually merge

# Continue
git add src/path/file.ts
git rebase --continue
```

## Decision Matrix

| Scenario | Strategy | Command |
|----------|----------|---------|
| < 10 commits behind | Full rebase | `./scripts/rebase-from-upstream.sh` |
| > 10 commits behind | Review first | `./scripts/compare-with-upstream.sh` |
| Specific feature wanted | Cherry-pick | `git cherry-pick <hash>` |
| Many conflicts expected | Feature branch | Manual integration + testing |
| Critical bug fix needed | Fast cherry-pick | `git cherry-pick -x <hash>` |
| Breaking API changes | Manual review | Review + incremental adoption |

## File Decision Guide

```
┌──────────────────┐
│ Conflicted File? │
└────────┬─────────┘
         │
    ┌────▼────────────────┐
    │ File Type?          │
    └─┬──────────────────┘
      │
      ├─ Config (package.json, biome.json)
      │  └─> Keep OURS (--ours)
      │      Reason: Preserve Bun architecture
      │
      ├─ Tooling (lefthook.yml, justfile)
      │  └─> Keep OURS (--ours)
      │      Reason: Fork-specific automation
      │
      ├─ Source (src/**/*.ts)
      │  └─> Prefer THEIRS (--theirs)
      │      Reason: Upstream improvements
      │      Action: Review & re-apply local enhancements
      │
      ├─ Tests (**/*.test.ts)
      │  └─> Prefer THEIRS (--theirs)
      │      Reason: Test coverage improvements
      │      Action: Verify with our mocks
      │
      └─ Docs (*.md)
         └─> MANUAL MERGE
             Reason: Keep both perspectives
```

## Emergency Procedures

### Abort and Restore

```bash
# During rebase, if things go wrong:
git rebase --abort

# Restore from backup
git reset --hard backup/before-rebase-<timestamp>

# Or check reflog
git reflog
git reset --hard HEAD@{n}
```

### Partial Success

```bash
# If some commits applied successfully before conflict:

# 1. Save current state
git rebase --abort
git stash

# 2. Create new branch
git checkout -b partial-integration

# 3. Cherry-pick successful commits only
git cherry-pick <hash1> <hash2> ...

# 4. Skip problematic commits for later
```

## Monitoring and Maintenance

### Weekly Check

```bash
# Add to cron or run manually
./scripts/compare-with-upstream.sh | tee upstream-status.log
```

### Monthly Integration

```bash
# Full workflow
./scripts/rebase-from-upstream.sh

# Or manual process:
# 1. Check readiness
# 2. Create backup
# 3. Rebase in feature branch
# 4. Test thoroughly
# 5. Merge to main
```

## Success Criteria

After rebase, verify:

- [ ] All tests pass: `bun run test:unit`
- [ ] Type checking: `bun run typecheck`
- [ ] Linting: `bun run lint`
- [ ] Build works: `bun run build`
- [ ] Git hooks: `lefthook run pre-commit`
- [ ] Manual testing: `bun run dev`
- [ ] Review commits: `git log --oneline`
- [ ] Check dependencies: `bun install`

## Additional Resources

- **Full Guide**: `REBASE-GUIDE.md` - Comprehensive documentation
- **Quick Ref**: `REBASE-QUICKREF.md` - One-page cheat sheet
- **Scripts**: `scripts/*.sh` - Automation tools
- **Upstream**: https://github.com/campfirein/cipher

---

**Remember**: When in doubt, test in a feature branch first!