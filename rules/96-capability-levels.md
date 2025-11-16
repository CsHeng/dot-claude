---
file-type: rule
---

## scope
REQUIRED: Apply these capability-level semantics to all agents and skills that declare `capability-level` in their manifests.

## absolute-prohibitions
PROHIBITED: Use capability levels outside the range 0–4  
PROHIBITED: Assign capability-level values that conflict with the declared role (agent vs skill)  
PROHIBITED: Encode capability semantics only in narrative text without clear labels  

## communication-protocol
REQUIRED: Describe capability-level expectations using terse, declarative statements  
REQUIRED: Reference capability-levels explicitly when documenting behaviors and acceptance criteria  
PROHIBITED: Implicit or ambiguous descriptions of agent or skill capabilities  

## structural-rules

### capability-levels-agents
REQUIRED: Interpret agent capability-levels as:
- 0: Single-step helper agents with no tool usage and no persistent state  
- 1: Tool-using helpers with stateless, short workflows  
- 2: Multi-step workflows with local task memory and deterministic phases  
- 3: Planning agents coordinating multiple phases, skills, or subagents  
- 4: Long-running system agents with monitoring, metrics, and self-healing behaviors  

REQUIRED: For level 3 agents:
- Provide a `Capability Profile` section describing planning behavior and orchestration scope  
- Document the execution loop (`loop-style`) and how it maps to phases or DEPTH-style steps  

REQUIRED: For level 4 agents (when introduced):
- Document monitoring responsibilities, rollback strategy, and health-check integration  

### capability-levels-skills
REQUIRED: Interpret skill capability-levels as:
- 0: Single-use helpers or thin wrappers around rules or tools  
- 1: Guidance or decision-support skills (language guidelines, search strategies)  
- 2: Stateful or multi-step skills applying rules with deterministic behavior  
- 3: Planning or orchestration skills coordinating other skills or tools  
- 4: System-level management skills with persistent coordination responsibilities  

REQUIRED: For level 2 and above:
- Provide IO semantics and deterministic steps in the body of the SKILL.md  

## language-rules
REQUIRED: Use consistent terminology for capability-levels in documentation and manifests  
REQUIRED: Refer to capability-level values by number (0–4) and role-specific meaning  

## formatting-rules
REQUIRED: Plain markdown with section headings as defined above  
REQUIRED: Use bullet lists to define expectations per level  
PROHIBITED: Bold markers in body content  

## naming-rules
REQUIRED: Use `capability-level` as the field name in manifests for level values  
REQUIRED: Use `mode` and `loop-style` for descriptive capability labels, not for numeric levels  

## validation-rules

### level-range
REQUIRED: Validate that all declared capability-level values are integers between 0 and 4  

### agent-level-expectations
REQUIRED: For level 3 agents, ensure:
- `Capability Profile` section exists in AGENT.md  
- `loop-style` is present in frontmatter  

OPTIONAL: For level 4 agents, enforce additional monitoring and rollback documentation in separate rules  

### skill-level-expectations
REQUIRED: For level 2 and above skills, ensure:
- `IO Semantics` section describes inputs, outputs, and side effects  
- `Deterministic Steps` section describes ordered behavior  

