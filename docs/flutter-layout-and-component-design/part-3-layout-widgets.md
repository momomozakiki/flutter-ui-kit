---
title: "Part 3 — Other Layout Widgets + Debugging"
parent: index.md
tags: [row, column, stack, expanded, sizedbox, layoutbuilder, debugging]
applies_when: "Choosing among Row/Column, Stack, Expanded/Flexible, SizedBox, AspectRatio, FittedBox, LayoutBuilder; debugging layout."
estimated_tokens: 1400
---

# Part 3: Other Important Layout Widgets – Visual Guide

> Part of the [Flutter Layout & Component Design guide](index.md).

## 3.1 `Row` and `Column` (Linear Layouts)

`Row` and `Column` are the most fundamental linear layout components in Flutter.

**Core Properties**:

| Property | Description |
| :--- | :--- |
| `mainAxisAlignment` | Alignment along the main axis. |
| `crossAxisAlignment` | Alignment along the cross axis. |
| `mainAxisSize` | Size on the main axis (`MainAxisSize.min` or `max`). |
| `children` | The list of child Widgets. |

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,   // Centered horizontally
  crossAxisAlignment: CrossAxisAlignment.center, // Centered vertically
  mainAxisSize: MainAxisSize.min,               // Minimum width
  children: [
    Icon(Icons.star),
    Text('Hello'),
    Icon(Icons.favorite),
  ],
)
```

**Visual effect** – `mainAxisAlignment` values (for Row, left‑to‑right):

| Value | Visual |
| :--- | :--- |
| `start` | `A B C       ` |
| `center` | `   A B C    ` |
| `end` | `       A B C` |
| `spaceBetween` | `A   B   C   ` |
| `spaceAround` | ` A  B  C  ` |
| `spaceEvenly` | `  A  B  C  ` |

**crossAxisAlignment** (for Row, top‑to‑bottom):
- `start` – items align at the top.
- `center` – items align at the vertical middle.
- `stretch` – items stretch to fill the cross‑axis height.

## 3.2 `Stack` and `Positioned` (Overlay Layout)

`Stack` allows child Widgets to overlap each other, similar to absolute positioning on the web.

```dart
Stack(
  alignment: Alignment.center,  // Default alignment for non-positioned children
  children: [
    Container(width: 200, height: 200, color: Colors.blue),
    Positioned(
      top: 20.0,
      left: 20.0,
      child: Icon(Icons.star, size: 50),
    ),
    Positioned(
      bottom: 20.0,
      right: 20.0,
      child: Text('Overlay'),
    ),
  ],
)
```

**Visual effect**: A blue square with a star icon overlapping near its top‑left corner. `Positioned` gives you pixel‑perfect control over the child's position relative to the Stack's edges.

## 3.3 `Expanded` and `Flexible` (Flexible Layouts)

Used within `Row`/`Column` to distribute remaining space.

```dart
Row(
  children: [
    Expanded(
      flex: 2,  // Takes up 2/3 of the available space
      child: Container(color: Colors.red),
    ),
    Expanded(
      flex: 1,  // Takes up 1/3 of the available space
      child: Container(color: Colors.blue),
    ),
  ],
)
```

**Visual effect**: The row's available width is divided into 3 equal parts. Red gets 2/3, blue gets 1/3.

```
┌─────────────────────────────┬──────────────────────────┐
│  Red (2/3)                  │       Blue (1/3)         │
└─────────────────────────────┴──────────────────────────┘
```

**`Expanded` vs. `Flexible`**:
- **`Expanded`**: Forces the child Widget to fill all remaining space (`FlexFit.tight`).
- **`Flexible`**: Allows the child Widget to be smaller than the allocated space (`FlexFit.loose`).

## 3.4 `SizedBox` (Fixed-Size Box)

Used to create a fixed-size space or force a child Widget to have a specific size.

```dart
// Fixed size
SizedBox(
  width: 50.0,
  height: 50.0,
  child: Container(color: Colors.red),
)

// Used for spacing
Column(
  children: [
    Text('First'),
    SizedBox(height: 20.0),  // Vertical spacer
    Text('Second'),
  ],
)

// Expand to fill the parent container
SizedBox.expand(
  child: Container(color: Colors.blue),
)
```

**Visual effect**: A fixed-size box or an invisible gap between elements.

## 3.5 `AspectRatio` (Aspect Ratio Control)

Maintains a specific aspect ratio for its child Widget.

```dart
AspectRatio(
  aspectRatio: 16 / 9,  // Aspect ratio 16:9
  child: Container(
    color: Colors.blue,
    child: Center(child: Text('16:9')),
  ),
)
```

**Visual effect**: The container will always be twice as wide as it is tall, adapting to the parent's width.

## 3.6 `FittedBox` (Scale to Fit)

Scales its child to fit within the available space.

```dart
Container(
  width: 200,
  height: 50,
  child: FittedBox(
    fit: BoxFit.contain,
    child: Text('Very Long Text', style: TextStyle(fontSize: 40)),
  ),
)
```

**Visual effect**: The text is scaled down to fit within the 200×50 box without overflowing.

**⚠️ Important**: `FittedBox` **requires its child to have an intrinsic size** (e.g., `Text`, `Image`, `Container` with fixed size). Placing widgets like `Expanded`, `FractionallySizedBox`, or an unconstrained `Container` inside it will cause layout errors or prevent scaling.

## 3.7 `LayoutBuilder` (Constraint-Aware Builder)

Builds widgets that can adapt to the parent's constraints.

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final availableWidth = constraints.maxWidth;
    if (availableWidth > 600) {
      return WideLayout();
    } else {
      return NarrowLayout();
    }
  },
)
```

**Use case**: Creating responsive layouts that change structure based on available space.

**Performance note**: `LayoutBuilder` rebuilds its subtree every time the parent constraints change. For highly dynamic animations, if the subtree is heavy, consider using `CustomSingleChildLayout` or custom `RenderObject` for smoother performance. For typical dashboards, it is perfectly fine.

---

## Part 4: Layout Debugging Tools

Enable layout debug visualization to inspect constraints and sizes:

```dart
import 'package:flutter/rendering.dart';

void main() {
  debugPaintSizeEnabled = true;  // Shows layout boundaries and constraints
  runApp(MyApp());
}
```

You will see coloured overlays that clearly show:
- **Margins** – light blue
- **Paddings** – light yellow
- **Alignments** – arrows
- **Bounds/Constraints** – solid black lines around each render object

---
Previous: [Part 2 — The `Container` widget](part-2-container.md) · Next: [Part 4 — Primitive UI components](part-4-primitive-components.md)
