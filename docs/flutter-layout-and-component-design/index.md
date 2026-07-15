---
title: Flutter Layout & Component Design – Complete Guide
version: 1.1
last_validated: 2026-07-15
official: unknown
source: origin unknown
tags: [layout, components, composition, responsive, guide, index]
applies_when: "Learning or deciding Flutter layout mechanics, responsive patterns, and component composition."
estimated_tokens: 500
---

# Flutter Layout & Component Design – Complete Guide
**Version 1.1** — *core layout mechanics → responsive patterns → component design.* Folded into a folder
(GUIDE §6.4) because the single file exceeded the Progressive Disclosure per-file token budget.

> **Provenance:** origin not yet confirmed (`official: unknown`). If adapted from an external source,
> add the URL/attribution and set `source`. This is **reference/teaching material**, not a canonical
> rule — the canonical rules live in the [golden-rule folder](../golden-rule/index.md).

## Revision History
| Version | Date       | Change |
|---------|------------|--------|
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
