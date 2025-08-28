# Vitest to Bun Test Migration

## Quick Migration Steps

1. **Update imports**:
   ```diff
   - import { describe, it, expect, vi } from 'vitest'
   + import { describe, it, expect, mock, spyOn } from 'bun:test'
   ```

2. **Update mock APIs**:
   ```diff
   - vi.mock('../module', () => ({ ... }))
   + mock.module('../module', () => ({ ... }))

   - const spy = vi.fn()
   + const spy = mock()

   - vi.spyOn(obj, 'method')
   + spyOn(obj, 'method')
   ```

3. **Update configuration**:
   - Remove `vitest.config.ts`
   - Update `package.json` test scripts
   - Remove vitest dependencies: `vitest`, `@vitest/coverage-v8`

4. **Run tests**: `bun test`

## What Stays the Same

- All test functions: `describe`, `it`, `test`, `expect`
- Lifecycle hooks: `beforeAll`, `beforeEach`, `afterAll`, `afterEach`
- Most assertion matchers: `.toBe()`, `.toEqual()`, etc.
- Test patterns: `.skip()`, `.only()`, `.todo()`

## Key Differences

- **Concurrency**: Bun runs tests concurrently by default
- **Mocks**: Different API but similar functionality
- **Coverage**: Built-in, simpler reporting
- **Config**: Uses `bunfig.toml` instead of `vitest.config.ts`

## Migration Strategy: Logical Batches

Migrate 96 tests in batches by complexity and functionality:

### Batch 1: Simple Tests (Low Risk)
```bash
# Start with simple tests (minimal mocking)
BATCH1="src/app/cli/__test__ src/core/logger/__test__ src/core/brain/embedding/__test__"
fd -e test.ts -e spec.ts . $BATCH1 | xargs ast-grep -p 'import { $$$ITEMS } from "vitest"' --rewrite 'import { $$$ITEMS } from "bun:test"'
bun test $BATCH1  # Validate this batch works
```

### Batch 2: Core Functionality
```bash
# Core brain and storage (moderate complexity)
BATCH2="src/core/brain/llm/compression src/core/brain/reasoning src/core/storage/__test__"
# Apply transformations, test, fix issues
```

### Batch 3: Complex Integrations
```bash
# Heavy mocking and integrations (high complexity)
BATCH3="src/core/session/__test__ src/core/vector_storage/__test__ src/core/mcp/__test__"
# Handle complex vi.mock patterns manually if needed
```

## Migration Commands

**Per-batch transformation**:
```bash
# Function to migrate a batch
migrate_batch() {
  local batch_paths="$1"
  echo "Migrating batch: $batch_paths"

  # 1. Update imports
  fd -e test.ts . $batch_paths | xargs ast-grep -p 'import { $$$ITEMS } from "vitest"' --rewrite 'import { $$$ITEMS } from "bun:test"'

  # 2. Update basic mock APIs
  fd -e test.ts . $batch_paths | xargs ast-grep -p 'vi.fn()' --rewrite 'mock()'
  fd -e test.ts . $batch_paths | xargs ast-grep -p 'vi.spyOn($OBJ, $METHOD)' --rewrite 'spyOn($OBJ, $METHOD)'

  # 3. Test the batch
  bun test $batch_paths
}

# Usage
migrate_batch "src/app/cli/__test__ src/core/logger/__test__"
```

**Check remaining patterns**:
```bash
# After each batch, check for complex patterns
fd -e test.ts . $BATCH_PATHS | xargs rg "vi\." --line-number
```

See `api-mapping.md` for detailed API reference.