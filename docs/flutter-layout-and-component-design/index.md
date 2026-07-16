---
title: Flutter Layout & Component Design – Complete Guide
version: 1.3
last_validated: 2026-07-17
official: false
source: agent-generated
tags: [layout, components, composition, responsive, guide, index]
applies_when: "Learning or deciding Flutter layout mechanics, responsive patterns, and component composition."
estimated_tokens: 500
---

# Flutter Layout & Component Design – Complete Guide
**Version 1.3** — *core layout mechanics → responsive patterns → component design.* Folded into a folder
(GUIDE §6.4) because the single file exceeded the Progressive Disclosure per-file token budget.

> **Provenance (confirmed 2026-07-17):** AI-distilled from online layout/component best-practice
> resources, then regenerated and reorganized in-repo (folded into this chunked folder for easier
> reference/indexing). `official: false`, `source: agent-generated`. This is **canonical
> reference/teaching material**, *not* a rule authority — the binding rules live in the
> [golden-rule folder](../golden-rule/index.md) (the contract is the single rule authority).

## Revision History
| Version | Date       | Change |
|---------|------------|--------|
| 1.3     | 2026-07-17 | Confirmed provenance: `official: unknown`→`false`, `source: origin unknown`→`agent-generated` (AI-distilled from online best practices, reorganized in-repo). Remains canonical reference, not a rule authority. |
| 1.2     | 2026-07-16 | Part 6: renamed the consumer-app example folder `composite/` → `screens/` so it no longer collides with the retired v0.4.0 kit layer name. |
| 1.1     | 2026-07-15 | Folded the single doc into this folder (index + 6 part files + CHANGELOG) per GUIDE §6.4. |
| 1.0     | 2026-07-11 | Added Documentation-Standard frontmatter. (Full history in [CHANGELOG.md](CHANGELOG.md).) |

This guide covers Flutter UI development end-to-end — core layout mechanics and the visual effect of
each widget, responsive patterns, primitive components, composition, and naming. Read the part you need:

## Contents

1. [Part 1 — Core layout mechanisms](part-1-core-layout.md) — the three layout principles + `BoxConstraints`.
2. [Part 2 — The `Container` widget](part-2-container.md) — complete constructor, every property with
   visual effects, and the sizing algorithm.
3. [Part 3 — Other layout widgets + debugging](part-3-layout-widgets.md) — `Row`/`Column`, `Stack`/
   `Positioned`, `Expanded`/`Flexible`, `SizedBox`, `AspectRatio`, `FittedBox`, `LayoutBuilder`, and
   `debugPaintSizeEnabled`.
4. [Part 4 — Primitive UI components](part-4-primitive-components.md) — buttons, text input, forms with
   validation, selection controls.
5. [Part 5 — Composition & custom design](part-5-composition.md) — composition over inheritance, the
   three ways to build custom components, worked examples.
6. [Part 6 — Naming conventions & best practices](part-6-naming-conventions.md) — naming, file
   organization, immutability/`const`, and external references.

## References

- [Flutter Layout Documentation](https://flutter.dev/docs/development/ui/layout)
- [Flutter Widget Catalog](https://flutter.dev/docs/development/ui/widgets)
- [Material Design 3 Guidelines](https://m3.material.io)
