# Provenance for workflow_config.json
- version: 1.1
- last_validated: 2026-07-11
- official: false
- source: agent-generated
- notes: Project-specific configuration for the Adaptive Self-Correcting Workflow
  (workflow-core submodule). Maps generic workflow concepts to this repo's paths.
  Validated against `.claude/workflow-core/schemas/config_schema.json` (whose
  `additionalProperties: true` permits the `workflow_update_check` key below).
  `env_check.tool_paths` is intentionally empty — the local supplement hook
  (`.claude/hooks/supplement.py`) owns the environment check via `.ai/env_check.ps1`
  (puro-aware), so the upstream hook emits no env line.
- v1.1 (2026-07-11): added the `workflow_update_check` block (enabled, submodule_path,
  remote, branch). Consumed by `supplement.py` to run the F5 daily workflow-update
  check. Proposed for the upstream `config_schema.json` (GUIDE §10).
