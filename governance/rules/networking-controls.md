---
name: rule-block:networking-controls
description: Apply networking and connectivity directives from rules/14-networking-guidelines.md.
layer: governance
sources:
  - rules/14-networking-guidelines.md
---

# Rule Block: Networking Controls

## Purpose

Expose networking and connectivity guidelines from `rules/14-networking-guidelines.md` so routers
can ensure that agents respect firewall, access-control, and connectivity constraints when
suggesting or executing network-related operations.

## Key Requirements (Referenced)

- Default-deny firewall posture with explicit allow rules for required services only.
- Proper segmentation between environments and security zones.
- Controlled outbound connectivity with audited exceptions.

## Application

- Routers that supervise network-affecting workflows SHOULD:
  - Load this rule-block when tasks involve service exposure, firewall changes, or network access.
  - Bias agent recommendations toward least-privilege, segmented architectures.
  - Require explicit justification for any relaxation of network controls.

