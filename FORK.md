# Cipher Fork Changes

This is an enhanced fork of [campfirein/cipher](https://github.com/campfirein/cipher) featuring modernization and tooling improvements.

## Major Changes

### Modernization Stack
- **Bun Migration**: Replaced Node.js/pnpm with Bun v1.2.21 for native TypeScript execution
- **Unified Tooling**: Replaced ESLint + Prettier with BiomeJS v2.2.2 for linting and formatting  
- **Modern Git Hooks**: Replaced Husky with Lefthook v1.12.3 for parallel pre-commit validation
- **Enhanced Docker**: Added multi-architecture buildx support

### Development Workflow
- **Quality Gates**: Pre-commit validation (format, typecheck, test, build) + pre-push integration testing
- **Parallel Execution**: Git hooks run validation tasks simultaneously for improved speed
- **Consistency**: Unified code standards across 387 files

### Fork Strategy
- **Automation**: Scripts for upstream monitoring and selective integration
- **Documentation**: Comprehensive fork management strategy in `/specs/fork-strategy/`
- **Framework Integration**: Context Engineering Framework patterns and specifications

For detailed fork management strategy, see [`/specs/fork-strategy/`](specs/fork-strategy/).