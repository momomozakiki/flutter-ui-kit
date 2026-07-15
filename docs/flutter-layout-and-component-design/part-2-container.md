---
title: "Part 2 — The Container Widget (Complete Visual Reference)"
parent: index.md
tags: [container, padding, margin, decoration, constraints]
applies_when: "Using Container: its constructor, every property's visual effect, and its sizing algorithm."
estimated_tokens: 1600
---

# Part 2: The Container Widget – Complete Visual Reference

> Part of the [Flutter Layout & Component Design guide](index.md).

`Container` is the most versatile layout Widget in Flutter, combining capabilities for painting, positioning, and sizing.

## 2.1 Complete Constructor

```dart
Container({
  Key? key,
  AlignmentGeometry? alignment,
  EdgeInsetsGeometry? padding,
  Color? color,
  Decoration? decoration,
  Decoration? foregroundDecoration,
  double? width,
  double? height,
  BoxConstraints? constraints,
  EdgeInsetsGeometry? margin,
  Matrix4? transform,
  AlignmentGeometry? transformAlignment,
  Widget? child,
  Clip clipBehavior = Clip.none,
})
```

## 2.2 Detailed Property Explanations with Visual Effects

### `width` and `height` (Size Control)

Directly set the fixed dimensions of the container.

```dart
Container(
  width: 200.0,    // Fixed width
  height: 100.0,   // Fixed height
  child: Text('Hello'),
)
```

**Visual effect**: A rectangle **exactly 200×100** (including padding).  
If set to `double.infinity`, the box **stretches** to fill the parent container.

**Important Notes**:
- The `width` and `height` values **include the `padding`**.
- If set to `null`, the dimensions are determined by the child Widget.
- If both `width`/`height` and `constraints` are provided, they are **merged** – the `width`/`height` values are clamped by the existing `min`/`max` of the `constraints` object, so `constraints` effectively take precedence in case of conflict.

### `margin` (Outer Space)

`margin` defines the empty space **outside** the container's border.

```dart
Container(
  margin: EdgeInsets.all(20.0),              // 20px on all sides
  margin: EdgeInsets.symmetric(               // 10px vertical, 20px horizontal
    vertical: 10.0,
    horizontal: 20.0,
  ),
  margin: EdgeInsets.only(                    // Specify individual sides
    left: 10.0,
    top: 20.0,
    right: 10.0,
    bottom: 20.0,
  ),
  child: Text('Hello'),
)
```

**ASCII diagram**:

```
┌──────────────────────────────────────┐
│            parent area               │
│  ┌──────────────────────────────┐   │
│  │      margin: 20px            │   │
│  │  ┌────────────────────────┐  │   │
│  │  │   Container (child)    │  │   │
│  │  └────────────────────────┘  │   │
│  └──────────────────────────────┘   │
└──────────────────────────────────────┘
```

The container is **pushed away** from other widgets by 20px on all sides.

### `padding` (Inner Space)

`padding` defines the empty space **inside** the container's border, surrounding its child Widget.

```dart
Container(
  padding: EdgeInsets.all(15.0),
  child: Text('Hello'),
)
```

**Visual effect**:

```
┌──────────────────────────┐
│    Container border       │
│  ┌────────────────────┐   │
│  │  padding: 20px     │   │
│  │  ┌──────────────┐  │   │
│  │  │  child (Text) │  │   │
│  │  └──────────────┘  │   │
│  └────────────────────┘   │
└──────────────────────────┘
```

The child is **inset** from the container's border by 20px.

### `margin` vs `padding` – Side‑by‑Side Visual

```
Margin (outside)          Padding (inside)
┌──────────────┐          ┌──────────────┐
│  margin      │          │  border      │
│  ┌────────┐  │          │  ┌────────┐  │
│  │ child  │  │          │  │ padding│  │
│  └────────┘  │          │  │ child  │  │
│              │          │  └────────┘  │
└──────────────┘          └──────────────┘
```

### `alignment` (Alignment)

Controls how the child Widget is positioned within the container.

```dart
Container(
  alignment: Alignment.center,        // Centered
  alignment: Alignment.topLeft,       // Top-left corner
  alignment: Alignment.bottomRight,   // Bottom-right corner
  alignment: Alignment(0.5, 0.5),     // Custom position (range: -1 to 1)
  child: Text('Hello'),
)
```

**Visual effect**:

```
Alignment.topLeft     Alignment.center     Alignment.bottomRight
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│ A            │      │              │      │            A │
│              │      │     A        │      │              │
│              │      │              │      │              │
└──────────────┘      └──────────────┘      └──────────────┘
```

### `color` and `decoration` (Styling)

```dart
// Using `color` (shorthand)
Container(
  color: Colors.blue,
  child: Text('Hello'),
)

// Using `decoration` (more expressive)
Container(
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12.0),
    border: Border.all(color: Colors.black, width: 2.0),
    boxShadow: [
      BoxShadow(
        color: Colors.grey,
        blurRadius: 5.0,
        offset: Offset(2.0, 2.0),
      ),
    ],
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.purple],
    ),
  ),
  child: Text('Hello'),
)
```

**Visual effect**: A box with background color, rounded corners, border, shadow, or gradient.

**Important**: `color` and `decoration` **cannot be used together**. If you need a color alongside other decorative properties, you must set the color inside `BoxDecoration`.

### `constraints` (Constraint Modifiers)

Apply additional size constraints to the container using `BoxConstraints`.

```dart
Container(
  constraints: BoxConstraints(
    minWidth: 100.0,
    maxWidth: 300.0,
    minHeight: 50.0,
    maxHeight: 150.0,
  ),
  child: Text('Hello'),
)
```

**Visual effect**: The container will be at least 100px wide and at most 300px wide. If the child is smaller than 100px, the container still grows to 100px. If the child wants to be wider than 300px, it is constrained.

### `transform` (Transformations)

Apply a 3D matrix transformation to the container.

```dart
Container(
  transform: Matrix4.rotationZ(0.2),    // Rotation
  transform: Matrix4.translationValues( // Translation
    10.0, 20.0, 0.0
  ),
  child: Text('Hello'),
)
```

**Visual effect**: The whole container is rotated, scaled, or translated.

### `clipBehavior` (Clipping Behavior)

Controls how the container's content is clipped.

| Value | Description |
| :--- | :--- |
| `Clip.none` | No clipping (default). |
| `Clip.hardEdge` | Hard-edged clipping. |
| `Clip.antiAlias` | Anti-aliased clipping. |
| `Clip.antiAliasWithSaveLayer` | Anti-aliased clipping with a save layer. |

## 2.3 Container Layout Algorithm – Step by Step

The `Container` determines its own size according to the following priority order:

1. **Honor `alignment`** – if an alignment is set, the container first sizes itself to **shrink‑wrap** the child (if no other constraints prevent it). The child is then placed according to that alignment.  
   *Note: This shrink‑wrap behavior only applies when the parent provides **loose** constraints. If the parent provides **tight** constraints, the container takes that exact size and `alignment` merely positions the child within it.*

2. **Size from child** – if no width/height/constraints are given, the container becomes exactly the size of its child.

3. **Apply `width`, `height`, and `constraints`** – these override the child‑driven size, but are merged (constraints clamp width/height). If both are given, `constraints` effectively take precedence.

4. **Expand to fill parent** – if there is no fixed size and the parent provides a loose constraint (e.g., `maxWidth` only), the container tries to fill the parent's available space.

5. **Shrink as small as possible** – if all else fails, the container becomes minimal (0×0) and the child may overflow.

---
Previous: [Part 1 — Core layout mechanisms](part-1-core-layout.md) · Next: [Part 3 — Other layout widgets + debugging](part-3-layout-widgets.md)
