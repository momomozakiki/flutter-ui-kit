# Provenance for workflow_config.json
- version: 1.0
- last_validated: 2026-07-11
- official: false
- source: agent-generated
- notes: Project-specific configuration for the Adaptive Self-Correcting Workflow
  (workflow-core submodule). Maps generic workflow concepts to this repo's paths.
  Validated against `.claude/workflow-core/schemas/config_schema.json`. `env_check.tool_paths`
  is intentionally empty — the local supplement hook (`.claude/hooks/supplement.py`) owns the
  environment check via `.ai/env_check.ps1` (puro-aware), so the upstream hook emits no env line.
