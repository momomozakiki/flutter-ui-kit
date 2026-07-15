---
title: "Part 1 — Core Layout Mechanisms"
parent: index.md
tags: [layout, constraints, boxconstraints]
applies_when: "Understanding how Flutter's constraint-based layout passes constraints down and sizes up."
estimated_tokens: 700
---

# Part 1: Core Layout Mechanisms

> Part of the [Flutter Layout & Component Design guide](index.md).

## 1.1 The Three Layout Principles

Flutter's layout system follows three core principles:

1. **Constraints go down** – The parent Widget passes constraints down to its child Widgets.
2. **Sizes go up** – The child Widget determines its own size and reports it back up to the parent Widget.
3. **Parent sets position** – The parent Widget determines the final position of its child Widgets.

The entire layout process is a **single‑pass layout**: constraints are passed down from the root of the render tree to the leaves, and then sizes are passed back up from the leaves to the root.

**Visual representation**:

```
Parent ──── constraints (min/max width/height) ────► Child
Child  ─────────── actual size ─────────────────────► Parent
Parent ─────────── final position ──────────────────► Child
```

## 1.2 BoxConstraints

`BoxConstraints` is the most important type of constraint in Flutter. It contains four numeric values:

| Property | Description |
| :--- | :--- |
| `minWidth` | The minimum width allowed. |
| `maxWidth` | The maximum width allowed. |
| `minHeight` | The minimum height allowed. |
| `maxHeight` | The maximum height allowed. |

**Key Terminology**:

- **Tight Constraint**: When the minimum and maximum values for a specific axis are equal, that axis is considered tightly constrained.
- **Loose Constraint**: When the minimum value for a specific axis is `0` (regardless of the maximum value).

```dart
// Tight constraint: Forces the child Widget to be exactly 100×100.
BoxConstraints.tight(Size(100, 100))

// Loose constraint: The child can be any size up to 100×100.
BoxConstraints.loose(Size(100, 100))
```

---
Next: [Part 2 — The `Container` widget](part-2-container.md)
