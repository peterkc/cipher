---
type: specification-overview
description: BiomeJS Migration - Navigation and Overview
version: 3.0.0
context: biome_migration
methodology: framework-specification-approach
project_reference: /repos/cipher/CLAUDE.md
---

# BiomeJS Migration Specification

## Overview

Replace ESLint + Prettier with BiomeJS unified toolchain for simplified development workflow and improved performance.

**Migration Goal**: Single dependency and configuration for both linting and formatting functionality.

## Framework Specification Structure

This specification follows the Framework methodology for simple projects:

```
specs/biome/
├── README.md              # This navigation and overview file
├── CLAUDE.md              # Operational context and methodology guidance
├── requirements.md        # User stories with results-validation EARS
├── design.md              # Current state analysis + architecture decisions  
└── tasks.md               # Implementation tracking and validation
```

## Quick Navigation

### **[Requirements](./requirements.md)** - User Stories & Acceptance Criteria
- **Unified Toolchain Migration**: Single BiomeJS package replaces 6 dependencies
- **Code Quality Preservation**: Maintain existing formatting and linting standards  
- **Workflow Integration**: Seamless pre-commit hooks and CI/CD compatibility

### **[Design](./design.md)** - Current State & Architecture Decisions
- **Current Environment**: ESLint 9.29.0 + Prettier 3.5.3 analysis
- **Configuration Mapping**: Rule translation and ignore pattern consolidation
- **Migration Strategy**: Automated migration with validation approach

### **[Tasks](./tasks.md)** - Implementation Progress
- **Phase 1**: BiomeJS installation and setup
- **Phase 2**: Configuration migration and testing
- **Phase 3**: Script integration and validation
- **Phase 4**: Cleanup and final verification

### **[CLAUDE.md](./CLAUDE.md)** - Operational Context
- Framework methodology guidance for this specification
- Implementation approach and evidence-based evolution

## Key Information References

- **Current & Target State**: See [Design - Current State Analysis](./design.md#current-state-analysis)
- **Implementation Commands**: See [Tasks - Implementation Progress](./tasks.md#implementation-progress)  
- **Success Criteria**: See [Requirements - Evidence-Based Validation](./requirements.md#evidence-based-validation)
- **Migration Strategy**: See [Design - Implementation Strategy](./design.md#implementation-strategy)

---
*Following Framework Specification Methodology v3.0 - structured navigation with evidence-based requirements*