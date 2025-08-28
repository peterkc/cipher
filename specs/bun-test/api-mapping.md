# API Mapping: Vitest → Bun Test

## Import Changes

```typescript
// Before
import { describe, it, expect, vi, beforeAll, afterEach } from 'vitest'

// After
import { describe, it, expect, mock, spyOn, beforeAll, afterEach } from 'bun:test'
```

## Mock API Changes

### Module Mocking
```typescript
// Before
vi.mock('../logger', () => ({
  logger: { info: vi.fn(), error: vi.fn() }
}))

// After
mock.module('../logger', () => ({
  logger: { info: mock(), error: mock() }
}))
```

### Function Mocking
```typescript
// Before
const mockFn = vi.fn()
const mockFnWithReturn = vi.fn(() => 'result')
const mockFnWithImplementation = vi.fn().mockImplementation(() => 'result')

// After
const mockFn = mock()
const mockFnWithReturn = mock(() => 'result')
const mockFnWithImplementation = mock(() => 'result')
```

### Spying
```typescript
// Before
const spy = vi.spyOn(obj, 'method')
vi.spyOn(console, 'log').mockImplementation(() => {})

// After
const spy = spyOn(obj, 'method')
spyOn(console, 'log').mockImplementation(() => {})
```

## Identical APIs (No Changes Needed)

- **Test functions**: `describe`, `it`, `test`
- **Lifecycle**: `beforeAll`, `beforeEach`, `afterAll`, `afterEach`
- **Modifiers**: `.skip()`, `.only()`, `.todo()`
- **Assertions**: All `expect()` matchers work identically

## Different Behavior

- **Concurrency**: Bun runs tests concurrently by default (no `describe.concurrent`)
- **Timeouts**: `test('name', fn, timeout)` instead of `test('name', fn, { timeout })`
- **Globals**: Explicit imports required (no global test functions)