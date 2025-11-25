# Governance Routers

This directory defines **Layer 2 routers** that decide which execution agents (Layer 3) to use
for a given task, based on memory, context, and rules.

Routers should reference rule-blocks under `governance/rules/` and avoid directly embedding tool
or filesystem details.
