# BiomeJS Migration Design

## Current State Analysis

### Systematic Environment Assessment

**Current Toolchain:**
- **ESLint**: `^9.29.0` with TypeScript plugin `^8.34.1`
- **Prettier**: `^3.5.3` with separate configuration
- **Configuration Files**: `eslint.config.js`, `.prettierrc`, `.prettierignore`
- **Package Scripts**: `lint`, `lint:fix`, `format`, `format:check`

**Configuration Analysis:**
```javascript
// eslint.config.js - Flat config format
- TypeScript-specific rules with explicit globals
- Custom ignore patterns for build outputs and dependencies  
- Rule overrides: no-console=off, no-unused-vars=warn, no-explicit-any=off

// .prettierrc
- printWidth: 100, tabWidth: 2, useTabs: true
- singleQuote: true, semi: true, trailingComma: es5
- lineEnding: lf, arrowParens: avoid
```

**Integration Points:**
- **Pre-commit Hook**: `precommit` script runs lint + typecheck + format:check + test:ci + build
- **CI/CD Integration**: Build process includes linting and formatting validation
- **Development Workflow**: Separate commands for linting and formatting operations

**Complexity Factors:**
- UI subproject has separate ESLint configuration (not included in this migration)
- Multiple ignore patterns across different tools need consolidation
- TypeScript-specific linting rules require careful mapping

### Configuration Mapping

| Current Tool | Target Tool | Configuration Equivalent | Notes |
|--------------|-------------|-------------------------|-------|
| `eslint ^9.29.0` | `@biomejs/biome` | Single package | Replaces 6 dependencies |
| `eslint.config.js` | `biome.json` | Unified config | Rules mapped to BiomeJS equivalents |
| `.prettierrc` | `biome.json` formatter | Format settings | Tab indentation, single quotes preserved |
| `.prettierignore` | `biome.json` files.ignore | Ignore patterns | Consolidated ignore patterns |

### Rule Translation Analysis
- **`no-console`**: `noConsoleLog` (disabled in both)
- **`no-unused-vars`**: `noUnusedVariables` (warning level maintained)  
- **`@typescript-eslint/no-explicit-any`**: `noExplicitAny` (disabled in both)
- **TypeScript parser**: Built into BiomeJS (no separate configuration needed)

## Architecture Decisions (Evidence-Based)

### Decision: Single BiomeJS Package Migration
**Rationale**: BiomeJS provides equivalent functionality to ESLint + Prettier with unified configuration and improved performance
**Alternatives Considered**: 
- Keep existing setup (rejected: maintenance overhead, tool coordination complexity)
- Migrate only ESLint or only Prettier (rejected: partial solution, still requires tool coordination)
**Trade-offs**: 
- **Gained**: Unified configuration, single dependency, faster execution
- **Lost**: Some ESLint ecosystem plugins (not needed for current ruleset)
**Evidence**: BiomeJS documentation shows equivalent rule coverage for our current setup

### Decision: Direct Configuration Migration
**Rationale**: BiomeJS provides automated migration tools for both ESLint and Prettier configurations
**Implementation Approach**:
```bash
# Use BiomeJS built-in migration commands
biome migrate eslint --write
biome migrate prettier --write
```
**Integration Impact**: Minimal - package scripts interface remains the same
**Validation Strategy**: Compare linting/formatting output before and after migration

### Decision: Consolidated Ignore Patterns
**Rationale**: Single configuration file allows unified ignore pattern management
**Current Patterns**:
- ESLint: `node_modules/**`, `dist/**`, `.cursor/**`, `src/app/ui/**`  
- Prettier: Similar patterns in `.prettierignore`
**Target Configuration**:
```json
{
  "files": {
    "ignore": [
      "node_modules/**", "dist/**", ".cursor/**", "public/**",
      "src/app/ui/.next/**", "src/app/ui/out/**", "**/build/**",
      "**/coverage/**", "test-temp/**", "**/*.min.js"
    ]
  }
}
```

## Implementation Strategy

### Migration Approach
1. **Install BiomeJS**: Add single dependency with exact version pinning
2. **Automated Configuration Migration**: Use BiomeJS migration commands
3. **Script Integration**: Update package.json scripts to use biome commands
4. **Validation**: Verify equivalent behavior on current codebase
5. **Cleanup**: Remove old dependencies and configuration files

### Risk Mitigation
- **Configuration Backup**: Keep original config files until validation complete
- **Rollback Plan**: Document steps to restore ESLint/Prettier if issues arise
- **Validation Approach**: Test on entire codebase before cleanup
- **Incremental Verification**: Validate each step before proceeding

### Performance Expectations
- **Baseline**: Current ESLint + Prettier execution time (unmeasured)
- **Target**: Faster execution with single-pass processing
- **Measurement Approach**: Time commands before/after migration for comparison

## Technical Specifications

### BiomeJS Configuration Structure
```json
{
  "$schema": "https://biomejs.dev/schemas/2.2.2/schema.json",
  "vcs": { "enabled": false, "clientKind": "git", "useIgnoreFile": false },
  "formatter": {
    "enabled": true,
    "indentStyle": "tab",
    "indentWidth": 2,
    "lineWidth": 100,
    "lineEnding": "lf",
    "useEditorconfig": true
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": false,
      "correctness": { "noUnusedVariables": "error" },
      "suspicious": { "noConsole": "off", "noExplicitAny": "off" }
    },
    "includes": [
      "**",
      "!node_modules/**", "!dist/**", "!.cursor/**", "!public/**",
      "!src/app/ui/.next/**", "!**/build/**", "!**/coverage/**"
    ]
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "semicolons": "always",
      "trailingCommas": "es5",
      "arrowParentheses": "asNeeded"
    }
  },
  "overrides": [
    {
      "includes": ["**/*.ts"],
      "javascript": { "globals": ["console", "process", "Buffer", "..."] },
      "linter": {
        "rules": {
          "correctness": { "noUnusedVariables": "warn" },
          "suspicious": { "noConsole": "off", "noExplicitAny": "off" }
        }
      }
    }
  ]
}
```

**Key Configuration Insights**:
- **Schema Version**: Using BiomeJS 2.2.2 (latest)
- **Comprehensive Globals**: Extensive TypeScript globals for different file types
- **File-Specific Overrides**: Separate rules for .ts, .js, config files, and client scripts
- **Consolidated Ignore Patterns**: Single configuration replaces ESLint and Prettier ignores

### Package Script Updates

**Current State (Not Yet Migrated)**:
```json
{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix", 
    "format": "prettier --write \"src/**/*.ts\" \"*.{js,json,md,yml,yaml}\"",
    "format:check": "prettier --check \"src/**/*.ts\" \"*.{js,json,md,yml,yaml}\"",
    "precommit": "bun run lint && bun run typecheck && bun run format:check && bun run test:ci && bun run build"
  }
}
```

**Proposed BiomeJS Script Migration**:
```json
{
  "scripts": {
    "check": "biome check .",
    "check:write": "biome check --write .",
    "lint": "biome lint .",
    "format": "biome format --write .",
    "format:check": "biome check --write=false .",
    "precommit": "bun run check:write && bun run typecheck && bun run test:ci && bun run build"
  }
}
```

---
*Design follows Framework specification methodology - current state analysis with evidence-based architecture decisions*