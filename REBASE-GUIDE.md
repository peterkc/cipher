# Upstream Rebase Guide for Cipher Fork

**Last Updated**: 2025-09-26
**Purpose**: Simple guide for rebasing upstream changes while keeping our Bun-first architecture

## Our Fork's Architecture

This fork maintains different tooling from upstream:

| Component | Upstream | Our Fork |
|-----------|----------|----------|
| Package Manager | pnpm | **Bun** |
| Linter/Formatter | ESLint + Prettier | **BiomeJS** |
| Git Hooks | Husky | **Lefthook** |
| Task Runner | npm scripts | **justfile** |
| Test Runtime | Node + Vitest | **Bun + Vitest** |

## The Simple Rebase Process

### 1. Create a Safety Backup

```bash
# Always create a backup first
git branch backup/before-rebase-$(date +%Y%m%d)
```

### 2. Fetch and Rebase

```bash
# Get latest upstream changes
git fetch upstream

# Start the rebase
git rebase upstream/main
```

### 3. Resolve Conflicts

When conflicts occur, follow this decision matrix:

#### Always Keep Ours (Our Architecture Files)
```bash
git checkout --ours package.json
git checkout --ours biome.json
git checkout --ours lefthook.yml
git checkout --ours justfile
git checkout --ours vitest.config.ts
git add <file>
```

#### Always Remove (Upstream's Tooling)
```bash
git rm pnpm-lock.yaml     # We use bun.lock
git rm package-lock.json   # We use bun.lock
git rm eslint.config.js    # We use BiomeJS
git rm .prettierrc         # We use BiomeJS
```

#### Manual Merge (Source Code)
For `src/**/*.ts` files, manually merge to include both:
- New features from upstream
- Our customizations

```bash
# Edit the file to resolve conflicts
vim src/path/to/file.ts
git add src/path/to/file.ts
```

### 4. Continue the Rebase

```bash
# After resolving all conflicts
git rebase --continue
```

### 5. Verify Everything Works

```bash
# Install dependencies
bun install

# Run tests
bun run test:unit

# Apply formatting
bun x biome check --write .

# Verify types (may have upstream errors, that's okay)
bun run typecheck
```

## Real-World Example: 2025-09-26 Rebase

Here's what actually happened when rebasing 19 commits from upstream:

### What We Integrated

**New Features from Upstream:**
- ✅ DeepSeek LLM provider (`src/core/brain/llm/services/deepseek.ts`)
- ✅ Built-in web search tool (`src/core/brain/tools/definitions/web-search/`)
- ✅ Session storage improvements (`src/core/session/session-manager.ts`)
- ✅ README updates (Codex compatibility docs)

**Conflicts We Resolved:**

1. **package.json** - Kept ours (Bun scripts)
2. **pnpm-lock.yaml** - Deleted (we use bun.lock)
3. **src/core/brain/llm/services/factory.ts** - Manual merge:
   ```typescript
   // Combined imports from both versions
   import { DeepseekService } from './deepseek.js';  // From upstream
   import { OllamaService } from './ollama.js';       // Already had
   import { OpenAIService } from './openai.js';       // Already had
   // ... etc
   ```
4. **src/core/brain/llm/services/index.ts** - Git rerere auto-resolved

### Results

```bash
$ bun install
99 packages installed [57.16s]

$ bun run test:unit
Test Files  1 failed | 83 passed
Tests       1454 passed | 67 skipped
Duration    43.04s

$ bun x biome check --write .
Checked 907 files. Fixed 334 files.
```

**Outcome**: Successfully integrated all upstream features while preserving Bun-first architecture.

## File Decision Reference

### Keep Ours (Fork Architecture)
```
package.json         # Bun workspace & scripts
bun.lock            # Bun dependency lock
biome.json          # BiomeJS config
lefthook.yml        # Git hooks
justfile            # Task automation
vitest.config.ts    # Bun test config
src/__mocks__/*     # Bun-specific mocks
```

### Delete Theirs (Upstream Tooling)
```
pnpm-lock.yaml      # pnpm lockfile
package-lock.json   # npm lockfile
eslint.config.js    # ESLint config
.prettierrc         # Prettier config
.prettierignore     # Prettier ignore
```

### Merge Carefully (Source Code)
```
src/**/*.ts         # Application code - take upstream, preserve our enhancements
src/**/*.test.ts    # Tests - take upstream, ensure our mocks work
README.md           # Documentation - merge both changes
```

## Emergency: Abort and Restore

If something goes wrong:

```bash
# Abort the rebase
git rebase --abort

# Restore from backup
git reset --hard backup/before-rebase-$(date +%Y%m%d)
```

## Common Scenarios

### Scenario: package.json Conflict

```bash
# Always keep our version
git checkout --ours package.json
git add package.json

# Review upstream's new dependencies
git show upstream/main:package.json | grep -A 50 '"dependencies"'

# Manually add any new dependencies we need
bun add <new-package>
```

### Scenario: New LLM Provider Added

```bash
# New provider file from upstream (e.g., deepseek.ts)
# Will auto-merge if no conflict

# factory.ts will need manual merge of imports
# Edit to include new provider import
vim src/core/brain/llm/services/factory.ts

# Add DeepseekService import
# Add case statement in switch
git add src/core/brain/llm/services/factory.ts
```

### Scenario: Test Mocks Need Updates

```bash
# If upstream changes APIs that our mocks use
# Update the mock to match new interface
vim src/__mocks__/bun-sqlite.ts

# Verify tests still pass
bun run test src/core/storage/__test__/sqlite.test.ts
```

## Tips for Success

1. **Read the upstream changes first**
   ```bash
   git log --oneline --graph upstream/main~20..upstream/main
   git diff --stat upstream/main~20..upstream/main
   ```

2. **Commit your guide updates before rebasing**
   - If you modify this guide, commit it before starting the rebase
   - Otherwise you'll have uncommitted changes blocking the rebase

3. **One conflict at a time**
   - Don't rush
   - Resolve each conflict completely before moving to the next
   - Use `git status` frequently to track progress

4. **Test early, test often**
   - After resolving conflicts, run `bun run test:unit`
   - Catch issues early before continuing

5. **Keep the backup branch**
   ```bash
   # Don't delete backup branches immediately
   # Keep them for a few days until confident
   git branch -D backup/before-rebase-YYYYMMDD  # Only after confident
   ```

## What to Do After Rebase

1. **Review the changes**
   ```bash
   git log --oneline -10
   git diff backup/before-rebase-$(date +%Y%m%d)..HEAD
   ```

2. **Run full verification**
   ```bash
   bun install
   bun run typecheck
   bun x biome check --write .
   bun run test:unit
   bun run build
   ```

3. **Document what was integrated**
   - Update CHANGELOG.md or commit message
   - Note any new features or fixes adopted
   - Document any architecture changes

4. **Push to your fork** (optional)
   ```bash
   git push origin feat/bun-test --force-with-lease
   ```

## Troubleshooting

### "Working tree not clean"
```bash
# Commit or stash your changes first
git status
git stash push -m "WIP before rebase"
```

### "Cannot find module after rebase"
```bash
# Reinstall dependencies
rm -rf node_modules bun.lock
bun install
```

### "Tests fail after rebase"
```bash
# Check if upstream changed APIs
git diff backup/before-rebase-$(date +%Y%m%d)..HEAD -- src/**/__test__/

# Update mocks if needed
vim src/__mocks__/bun-sqlite.ts
```

### "Too many conflicts"
```bash
# Abort and try cherry-picking specific commits instead
git rebase --abort
git log --oneline upstream/main~10..upstream/main
git cherry-pick <commit-hash>  # Pick specific commits
```

## Resources

- **Upstream Repository**: https://github.com/campfirein/cipher
- **Bun Documentation**: https://bun.sh/docs
- **BiomeJS Guide**: https://biomejs.dev/
- **Lefthook Documentation**: https://github.com/evilmartians/lefthook

---

**Remember**: The backup branch is your safety net. When in doubt, abort and try again!