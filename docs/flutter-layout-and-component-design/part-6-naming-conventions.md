---
title: "Part 6 — Naming Conventions & Best Practices"
parent: index.md
tags: [naming, file-organization, immutability, const]
applies_when: "Naming widgets/classes/members; organizing files; applying immutability and const constructors."
estimated_tokens: 500
---

# Part 7: Naming Conventions & Best Practices

> Part of the [Flutter Layout & Component Design guide](index.md). *(Numbered "Part 7" in the original
> single-file guide.)* For this repo's **binding** naming rules, see the
> [design-system contract](../golden-rule/design-system-contract.md) and [`.ai/naming_conventions.md`](../../.ai/naming_conventions.md);
> the below is the general-Flutter reference.

## 7.1 Naming Conventions

**Widgets and Classes:**
- Use **PascalCase** for all class names (e.g., `MyCustomButton`, `FormContainer`).
- **Prefer descriptive names** that convey purpose (e.g., `ConnectivityIndicator` instead of `Indicator`).

**Variables and Properties:**
- Use **camelCase** for variables, properties, and function names.
- **Avoid abbreviations** unless universally recognized (e.g., `config` is fine, `cfg` is not).

**Private members:**
- Prefix private members with underscore: `_privateVariable`, `_PrivateClass`.

## 7.2 File Organization

```
lib/
├── src/
│   ├── screens/       # Custom app-specific screens and layouts
│   ├── widgets/       # Reusable UI components (non-kit)
│   ├── utils/         # Helper functions and utilities
│   ├── models/        # Data models
│   └── services/      # Business logic and data services
├── main.dart          # Entry point
└── app.dart           # Root app widget
```

## 7.3 Immutability & const Constructors

Always make widgets immutable and use `const` constructors:

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({
    required this.title,
    this.onPressed,
    super.key,
  });

  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => /* ... */;
}
```

## References

- [Flutter Layout Documentation](https://flutter.dev/docs/development/ui/layout)
- [Flutter Widget Catalog](https://flutter.dev/docs/development/ui/widgets)
- [Material Design 3 Guidelines](https://m3.material.io)

---
Previous: [Part 5 — Composition & custom design](part-5-composition.md) · Back to [index](index.md)
