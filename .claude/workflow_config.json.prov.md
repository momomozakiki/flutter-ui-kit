# Provenance for workflow_config.json
- version: 1.2
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
  remote, branch). Kept `enabled: true` (upstream default is `false`/opt-in — we
  deliberately opt in).
- v1.2 (2026-07-11): the key is now a first-class property of the upstream
  `schemas/config_schema.json` (submodule bumped 91a4163 → 5c2128d), and the F5 check
  is now performed by the upstream `workflow_hook.py`. The local `supplement.py` F5
  implementation was retired; this config block now drives the upstream check.
