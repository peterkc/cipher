# Upstream Rebase Quick Reference

**🎯 Goal**: Safely integrate upstream changes while preserving our Bun-first architecture

## The Process (5 Steps)

```bash
# 1. Create backup
git branch backup/before-rebase-$(date +%Y%m%d)

# 2. Fetch and rebase
git fetch upstream
git rebase upstream/main

# 3. When conflicts occur:
#    - Keep ours: package.json, biome.json, lefthook.yml, justfile
#    - Delete theirs: pnpm-lock.yaml, eslint.config.js, .prettierrc
#    - Manual merge: src/**/*.ts files

# 4. After resolving conflicts
git rebase --continue

# 5. Verify
bun install
bun run test:unit
bun x biome check --write .
```

## Critical File Decisions

| File | Action | Command |
|------|--------|---------|
| `package.json` | Keep ours | `git checkout --ours package.json` |
| `biome.json` | Keep ours | `git checkout --ours biome.json` |
| `lefthook.yml` | Keep ours | `git checkout --ours lefthook.yml` |
| `justfile` | Keep ours | `git checkout --ours justfile` |
| `pnpm-lock.yaml` | Delete | `git rm pnpm-lock.yaml` |
| `eslint.config.js` | Delete | `git rm eslint.config.js` |
| `src/**/*.ts` | Manual merge | Edit file, then `git add` |

## Common Conflict Patterns

### Package.json Conflict
```bash
git checkout --ours package.json
git add package.json
# Review upstream dependencies, add if needed:
git show upstream/main:package.json | grep -A 30 dependencies
bun add <new-package>
```

### LLM Service Factory Conflict
```bash
# Merge imports from both versions
vim src/core/brain/llm/services/factory.ts
# Include both our imports AND new provider imports
git add src/core/brain/llm/services/factory.ts
```

### Lockfile Conflicts
```bash
git rm pnpm-lock.yaml package-lock.json
# Regenerate our lockfile after rebase
bun install
```

## Emergency Commands

```bash
# Abort rebase
git rebase --abort

# Restore from backup
git reset --hard backup/before-rebase-$(date +%Y%m%d)

# See current conflict status
git status

# See what changed
git diff HEAD
```

## Real Example (2025-09-26)

**Integrated**: 19 upstream commits including DeepSeek provider, web search tool, session storage fixes

**Conflicts Resolved**:
- ✅ `package.json` → Kept ours (Bun config)
- ✅ `pnpm-lock.yaml` → Deleted
- ✅ `factory.ts` → Manual merge (added DeepSeek import)
- ✅ `index.ts` → Git rerere auto-resolved

**Result**: 1454 tests passed, all features integrated, architecture preserved

## Our Fork's Identity

```
package.json         # Bun workspace
bun.lock            # Bun dependencies
biome.json          # BiomeJS linting
lefthook.yml        # Git hooks
justfile            # Task runner
src/__mocks__/*     # Bun test mocks
```

**Never compromise on these files** - they define our fork's architecture.

## Help

- Full guide: `REBASE-GUIDE.md`
- Upstream: https://github.com/campfirein/cipher
- Issues: Check troubleshooting section in full guide