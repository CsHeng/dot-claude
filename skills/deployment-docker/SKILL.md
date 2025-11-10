---
name: "skill:deployment-docker"
description: "Apply Docker/container guidelines"
tags: [deployment, docker]
source:
  - rules/13-docker-guidelines.md
allowed-tools: []
capability:
  - "Enforce base image selection, multi-stage builds, and size optimization"
  - "Document networking/volume considerations per `rules/13`"
usage:
  - "Load for agents handling Dockerfiles or deployment scripts"
validation:
  - "`docker build` / lint tools (hadolint) as needed"
fallback: ""
---

## Notes
- Pair with `skill:security-guardrails` for production deployments.
