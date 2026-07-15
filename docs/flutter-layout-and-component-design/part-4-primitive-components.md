---
title: "Part 4 — Primitive UI Components (Quick Reference)"
parent: index.md
tags: [buttons, textfield, form, validation, selection-controls]
applies_when: "Using Flutter's built-in primitives: buttons, text input, forms with validation, selection controls."
estimated_tokens: 700
---

# Part 5: Primitive UI Components – Quick Reference

> Part of the [Flutter Layout & Component Design guide](index.md). *(Numbered "Part 5" in the original
> single-file guide; it is the 4th reading section in this folder.)*

Flutter provides a rich set of built-in components. Here's how to use the most common ones.

## 5.1 Buttons

Flutter offers several button types for different emphasis levels:

| Button | Use Case |
| :--- | :--- |
| `ElevatedButton` | Primary actions (e.g., Submit, Save) |
| `TextButton` | Secondary or less prominent actions |
| `OutlinedButton` | Medium emphasis actions |
| `IconButton` | Icon-only actions |

**Basic usage**:

```dart
ElevatedButton(
  onPressed: () { /* action */ },
  child: Text('Submit'),
)
```

**Key points**:
- `onPressed` being `null` automatically disables the button.
- Use `style` parameter for customizations (colors, shape, padding).

## 5.2 Text Input

`TextField` is the primary input component:

```dart
TextField(
  controller: _controller,          // For programmatic access
  decoration: InputDecoration(
    hintText: 'Enter text',
    border: OutlineInputBorder(),   // Adds a border
    prefixIcon: Icon(Icons.person), // Leading icon
  ),
  obscureText: true,                // For password fields
  keyboardType: TextInputType.number,
  maxLines: 3,                      // Multi-line input
  onChanged: (value) { /* real-time updates */ },
)
```

**Getting input value**:
```dart
final controller = TextEditingController();
// Later: controller.text
```

## 5.3 Form with Validation

For forms with validation, use `Form` and `TextFormField`:

```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Form is valid, submit
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

## 5.4 Selection Controls

| Control | Code |
| :--- | :--- |
| Checkbox | `Checkbox(value: isChecked, onChanged: (v) {})` |
| Switch | `Switch(value: isOn, onChanged: (v) {})` |
| Radio | `Radio(value: option, groupValue: selected, onChanged: (v) {})` |
| Slider | `Slider(value: val, min: 0, max: 100, onChanged: (v) {})` |

---
Previous: [Part 3 — Other layout widgets + debugging](part-3-layout-widgets.md) · Next: [Part 5 — Composition & custom design](part-5-composition.md)
