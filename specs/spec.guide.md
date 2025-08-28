---
type: specification-guide
description: Lean specification methodology guide based on Bun migration retrospective learnings
version: 2.0.0
context: lean_specification_methodology
template_reference: /repos/cipher/specs/spec.template.md
methodology_evidence: /repos/cipher/specs/use-bun/lessons.md
---

# Lean Specification Guide - Results-Driven Documentation

## Core Philosophy: "Simple Solutions That Work"

**Evidence-Based Approach**: This guide reflects proven learning from the Bun migration where 18 specification files were reduced to 5 essential files with 100% retention of value.

**Key Principle**: Specifications should capture what we learned, not predict what we need.

## Framework Specification Structure

### **Universal Structure:**

```
specs/[spec-name]/
├── CLAUDE.md              # Context integration
├── requirements.md        # Results-validation EARS (not predictive requirements)
├── design.md              # Architecture decisions made (not predicted designs)
├── tasks.md               # Implementation log and tracking (not upfront task planning)
├── completion.md          # Results and achievements  
└── lessons.md             # Methodology insights and future improvements
```

**Evolution**: Integrates structured analysis with evidence-based documentation principles - document decisions made, not predictions of what might be needed.

## Framework Specification Process

### **Phase 1: Evidence-Based Foundation**
- Create CLAUDE.md for operational context
- Start requirements.md with critical constraints only (results-validation EARS)
- Begin design.md with known architecture decisions
- Initialize tasks.md as implementation log

### **Phase 2: Iterative Documentation**
- Update requirements.md with validated requirements as they emerge
- Document architecture decisions in design.md as they're made
- Log implementation progress and discoveries in tasks.md
- Capture performance data and key decisions continuously

### **Phase 3: Results Synthesis**
- Complete requirements.md with final validated requirements
- Finalize design.md with actual architecture implemented
- Close tasks.md with implementation summary and blockers resolved
- Create completion.md with measurable achievements
- Write lessons.md with methodology insights for future projects

### **Key Evolution: Evidence-First, Not Prediction-First**
- **Traditional Kiro**: Write requirements → Design system → Execute tasks
- **Evolved Kiro-Cipher**: Discover constraints → Document decisions → Log progress → Synthesize results

### **File-Specific Guidelines**

#### **requirements.md (Results-Validation EARS)**
- **✅ Use for**: Critical safety constraints, integration requirements, measurable outcomes
- **❌ Avoid**: Performance predictions, theoretical capabilities, comprehensive feature lists
- **Format**: `The system SHALL [verifiable behavior]` with evidence-based validation
- **Evolution**: Start minimal, add requirements as they're validated during implementation

#### **design.md (Architecture Decisions)**
- **✅ Use for**: Key architecture decisions made, technology choices with rationale, integration patterns
- **❌ Avoid**: Theoretical system designs, comprehensive documentation of obvious patterns
- **Focus**: Decision rationale with evidence, performance implications, alternative approaches considered
- **Evolution**: Document decisions as they're made, not comprehensive upfront design

#### **tasks.md (Implementation Log)**
- **✅ Use for**: Implementation progress, blockers encountered and resolved, key discoveries
- **❌ Avoid**: Detailed upfront task planning, comprehensive project management
- **Format**: Chronological log of what was done, what worked, what didn't
- **Evolution**: Living document updated as implementation progresses

### **What NOT to Create**

❌ **Predictive Requirements**: Write requirements only after validation  
❌ **Comprehensive System Design**: Document decisions made, not theoretical architecture  
❌ **Detailed Task Planning**: Log implementation progress, don't predict every task  
❌ **Process Documentation**: Document results and decisions, not processes  

## Template Usage - Simplified

### **Step 1: Copy Lean Template**
```bash
cp /repos/cipher/specs/spec.template.md /repos/cipher/specs/[spec-name]/CLAUDE.md
```

### **Step 2: Replace Core Variables**
| **Variable** | **Purpose** | **Examples** |
|---|---|---|
| `[SPEC_NAME]` | Brief specification name | "API Migration", "Database Upgrade" |
| `[spec-name]` | Directory-safe name | "api-migration", "database-upgrade" |
| `[technology]` | Primary technology | "graphql", "postgresql", "docker" |

### **Step 3: Focus on Technology Context**
- What are the specific technical constraints?
- How does this technology integrate with existing systems?
- What performance characteristics matter?

## Evidence from Bun Migration

### **What Provided Value:**
- **Phase structure** for learning iteration
- **Performance measurements** (7.83s installs, 109MB executables)  
- **Implementation results** (Docker infrastructure details)
- **Decision documentation** with evidence and rationale
- **Lessons learned** for future methodology improvement

### **What Was Over-Engineering:**
- Separate requirements files for every category
- Detailed acceptance criteria never referenced during work
- Extensive upfront planning that got simplified in practice
- Complex theoretical validation replaced by working solutions

## Specification Examples

### **Good: Bun Migration (After Cleanup)**
```
use-bun/
├── CLAUDE.md                   # Context integration
├── README.md                   # Phase overview and navigation
├── completion.md               # Results: 7.83s installs, 109MB executables, Docker working
├── lessons.md                  # "Simple solutions that work" principle
└── implementation/
    └── docker-structure.md     # 8-file Docker implementation vs 23 planned
```

### **Avoid: Original Bun Migration (Before Cleanup)**
```
use-bun/                        # 20 files total
├── requirements/               # 3 files - never referenced during implementation
├── acceptance/                 # 2 files - theoretical criteria unused
├── results/                    # 5 files - over-documentation
└── implementation/             # 8 files - mostly redundant planning
```

## Results-Validation EARS (Enhancement)

**Lean + EARS Integration**: Use EARS syntax for results validation rather than upfront requirements.

### **EARS for Critical Constraints**
```
The migration SHALL preserve existing code formatting
WHEN config migration completes, the system SHALL maintain current linting behavior  
The validation phase SHALL confirm zero formatting changes before cleanup
```

### **Evidence-Based EARS Validation**
Document completion criteria with measurable verification:
```
## Completion Validation
✅ The migration SHALL remove 6 linting dependencies → VERIFIED: package.json shows single @biomejs/biome
✅ WHEN tests execute, the build SHALL complete without errors → VERIFIED: CI passes
✅ The cleanup SHALL remove old configs only after validation → VERIFIED: git diff shows removed files
```

### **EARS Usage Guidelines**
- **✅ Use for**: Critical safety requirements, measurable outcomes, integration constraints
- **❌ Avoid for**: Performance predictions, theoretical capabilities, marketing claims
- **Focus**: What MUST work based on evidence, not what SHOULD exist based on speculation

## Quality Principles

### **Do More:**
✅ **Measure and document performance results**  
✅ **Capture key decisions with evidence and rationale**  
✅ **Document what actually worked and why**  
✅ **Apply "simple solutions that work" from the beginning**  
✅ **Keep specifications simple and actionable**  
✅ **Use results-validation EARS for critical requirements**

### **Do Less:**
❌ **Predict detailed requirements that won't be referenced**  
❌ **Create complex acceptance criteria for theoretical scenarios**  
❌ **Over-specify implementation approaches**  
❌ **Document processes instead of results**  
❌ **Plan comprehensively instead of iterating based on evidence**  
❌ **Use predictive EARS for unvalidated performance claims**  

## DRY Principles for Specifications

### **Information Lives in One Place**
- **Navigation**: README.md provides overview and references to detailed information
- **Requirements**: User stories and acceptance criteria only in requirements.md
- **Technical Details**: Architecture decisions and current state analysis only in design.md
- **Implementation**: Progress tracking and commands only in tasks.md
- **Context**: Operational guidance only in CLAUDE.md

### **Use References, Not Duplication**
```markdown
## Key Information References
- **Current State**: See [Design - Current State Analysis](./design.md#current-state-analysis)
- **Commands**: See [Tasks - Implementation Progress](./tasks.md#implementation-progress)
- **Success Criteria**: See [Requirements - Evidence-Based Validation](./requirements.md#evidence-based-validation)
```

### **Red Flags for Duplication**
❌ **Command examples repeated** across multiple files  
❌ **Validation criteria copied** from requirements to tasks  
❌ **Current state info duplicated** in README and design  
❌ **Implementation approach repeated** in multiple locations  

### **DRY Validation Checklist**
- [ ] Each piece of information exists in exactly one file
- [ ] Cross-references use specific anchor links
- [ ] No command examples duplicated across files  
- [ ] Validation criteria referenced, not repeated
- [ ] Technical details consolidated in appropriate files

## Success Validation

**A successful Framework specification:**
- ✅ Provides all essential information in minimal files
- ✅ Documents actual results rather than theoretical planning
- ✅ Enables future projects through lessons learned
- ✅ Captures key decisions with evidence-based rationale
- ✅ Demonstrates measurable achievements

**Red flags indicating over-engineering:**
- ❌ Excessive specification files (Bun migration: 20→5 files provided same value)
- ❌ Detailed upfront requirements that aren't referenced during implementation
- ❌ Complex theoretical acceptance criteria
- ❌ Process documentation without results
- ❌ Comprehensive planning without experimental validation

## Migration Guide: Complex → Lean

If you have over-engineered specifications:

1. **Audit actual usage** - Which files were referenced during implementation?
2. **Extract essential results** - What performance data and key decisions matter?
3. **Create completion summary** - Document what was achieved
4. **Document lessons learned** - What methodology insights emerged?
5. **Remove theoretical files** - Eliminate unused planning documentation

**Evidence**: Bun migration reduced from 20 files to 5 files with 100% value retention.

## Contributing Improvements

### **Results-Driven Enhancement**
When your specification discovers valuable patterns:
1. **Document with evidence** - What worked and why?
2. **Measure the impact** - What performance improvements resulted?
3. **Capture lessons learned** - How does this improve future specifications?
4. **Update methodology** - Enhance this guide with proven insights

This creates a continuous improvement cycle where each specification makes future specifications better through evidence-based learning rather than theoretical planning.

---
*Framework specification methodology based on proven results with evidence-based improvements and DRY principles.*