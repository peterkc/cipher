# Cipher Fork Management Scripts

Automated tooling for managing the cipher fork and upstream synchronization.

## Rebase & Sync Scripts (New)

### 🔍 Pre-Rebase Analysis

**`compare-with-upstream.sh`** - Comprehensive diff analysis
```bash
./scripts/compare-with-upstream.sh
```
- Shows commit divergence (ahead/behind)
- Lists file differences
- Compares key config files
- Predicts potential conflicts
- Analyzes dependency changes

**`check-rebase-readiness.sh`** - Validates rebase prerequisites
```bash
./scripts/check-rebase-readiness.sh
```
- Checks working tree cleanliness
- Verifies upstream remote configuration
- Runs test suite validation
- Confirms backup branch status

### 🔄 Rebase Execution

**`rebase-from-upstream.sh`** - Automated rebase workflow
```bash
./scripts/rebase-from-upstream.sh
```
- Creates backup branch automatically
- Creates integration branch
- Performs rebase with safety checks
- Auto-resolves config conflicts
- Runs tests post-rebase

### 🔧 Conflict Resolution

**`resolve-rebase-conflicts.sh`** - Auto-resolve tooling conflicts
```bash
./scripts/resolve-rebase-conflicts.sh
```
- Automatically keeps our versions of:
  - `package.json` (Bun vs pnpm)
  - `biome.json` (BiomeJS vs ESLint)
  - `lefthook.yml` (Lefthook vs Husky)
  - `justfile` (our task automation)
- Reports remaining conflicts for manual resolution

## Fork Health Monitoring (Existing)

**`fork-health.sh`** - Fork divergence metrics
```bash
./scripts/fork-health.sh
```
- Shows commits ahead/behind upstream
- Tracks fork health over time

**`sync-upstream.sh`** - Upstream sync assistant
```bash
./scripts/sync-upstream.sh
```
- Fetches latest upstream changes
- Analyzes compatibility

**`upstream-intelligence.sh`** - Change analysis
```bash
./scripts/upstream-intelligence.sh
```
- Analyzes upstream changes since baseline
- Evaluates change impact

## Quick Start Workflows

### 1. Regular Monthly Sync

```bash
# Check what's new
./scripts/compare-with-upstream.sh

# Verify readiness
./scripts/check-rebase-readiness.sh

# Perform automated rebase
./scripts/rebase-from-upstream.sh
```

### 2. Check Fork Health

```bash
# Quick health check
./scripts/fork-health.sh

# Detailed comparison
./scripts/compare-with-upstream.sh
```

### 3. Manual Rebase with Helper

```bash
# Start manual rebase
git checkout -b integrate/upstream-$(date +%Y%m%d)
git rebase upstream/main

# When conflicts occur
./scripts/resolve-rebase-conflicts.sh

# Continue after resolving
git rebase --continue
```

## Script Interactions

```
Fork Health Monitoring:
  fork-health.sh ──> Quick status check
  upstream-intelligence.sh ──> Detailed analysis
       │
       ▼
Pre-Rebase Analysis:
  compare-with-upstream.sh ──> Comprehensive diff
  check-rebase-readiness.sh ──> Validation
       │
       ▼
Rebase Execution:
  rebase-from-upstream.sh ──> Automated workflow
       │
       ├─> Creates backup
       ├─> Creates integration branch
       ├─> Runs rebase
       └─> Calls resolve-rebase-conflicts.sh
                │
                ▼
Conflict Resolution:
  resolve-rebase-conflicts.sh ──> Auto-resolve configs
       │
       ▼
Manual fixes if needed
       │
       ▼
Test & Merge
```

## Configuration

### Files Always Kept (Ours)

The scripts automatically preserve our fork's architectural decisions:

```bash
package.json         # Bun workspace vs pnpm
bun.lock            # Bun lockfile
biome.json          # BiomeJS vs ESLint/Prettier
lefthook.yml        # Lefthook vs Husky
justfile            # Task automation
vitest.config.ts    # Test config with Bun compatibility
src/__mocks__/*     # Runtime-specific mocks
```

### Customization

Edit these arrays in `resolve-rebase-conflicts.sh`:

```bash
# Files to keep our version
KEEP_OURS=(
    "package.json"
    "biome.json"
    # Add more...
)

# Files to take upstream version
TAKE_THEIRS=(
    # Add files that should always come from upstream
)
```

## Error Handling

### Script Fails - Working Tree Not Clean

```bash
# Stash changes
git stash push -m "WIP before rebase"

# Or commit changes
git add .
git commit -m "wip: prepare for rebase"
```

### Rebase Fails - Too Many Conflicts

```bash
# Abort the rebase
git rebase --abort

# Use cherry-pick instead
git log upstream/main --oneline | head -10
git cherry-pick <specific-commit>
```

### Tests Fail After Rebase

```bash
# Check what changed
git diff upstream/main..HEAD -- src/

# Run specific test for debugging
bun run test <failing-test> --reporter=verbose
```

## Integration with Justfile

Add to your `justfile`:

```just
# Check upstream status
upstream-status:
    ./scripts/compare-with-upstream.sh

# Full rebase workflow
rebase-upstream:
    ./scripts/check-rebase-readiness.sh
    ./scripts/rebase-from-upstream.sh

# Health check
fork-health:
    ./scripts/fork-health.sh
```

Then use:
```bash
just upstream-status
just rebase-upstream
just fork-health
```

## Documentation

- **REBASE-GUIDE.md** - Comprehensive 640-line guide
- **REBASE-QUICKREF.md** - One-page quick reference
- **.github/REBASE-WORKFLOW.md** - Visual workflows and decision trees

## Maintenance

### Update Scripts

Scripts are versioned with the repository. To update:

```bash
# Pull latest scripts
git pull origin main -- scripts/

# Make executable (if needed)
chmod +x scripts/*.sh
```

### Add New Scripts

1. Create script in `scripts/`
2. Make executable: `chmod +x scripts/new-script.sh`
3. Add documentation to this README
4. Test thoroughly before committing

## Troubleshooting

### Permission Denied

```bash
chmod +x scripts/*.sh
```

### Script Not Found

```bash
# Run from repository root
cd /path/to/cipher
./scripts/script-name.sh
```

### Git Remote Errors

```bash
# Ensure upstream is configured
git remote add upstream git@github.com:campfirein/cipher.git
git fetch upstream
```

## Best Practices

1. **Run health checks weekly**: `./scripts/fork-health.sh`
2. **Compare before rebasing**: `./scripts/compare-with-upstream.sh`
3. **Always validate readiness**: `./scripts/check-rebase-readiness.sh`
4. **Test in feature branches**: Use integration branches for safety
5. **Keep backups**: Scripts automatically create backup branches

## Contributing

When adding new fork management scripts:

1. Follow existing naming conventions
2. Include comprehensive error handling
3. Add color-coded output (GREEN=success, YELLOW=warning, RED=error)
4. Document in this README
5. Add examples to documentation

## License

Same as main repository.