---
title: "Part 5 — Component Composition & Custom Design"
parent: index.md
tags: [composition, custom-widgets, custompaint, renderobject]
applies_when: "Building custom components by composition; deciding between composition, CustomPaint, and RenderObject."
estimated_tokens: 900
---

# Part 6: Component Composition & Custom Design

> Part of the [Flutter Layout & Component Design guide](index.md). *(Numbered "Part 6" in the original
> single-file guide.)*

Flutter's core design philosophy is **"Composition over Inheritance"** – you build new components by combining existing ones, not by extending them.

## 6.1 Why Composition?

| Advantage | Description |
| :--- | :--- |
| **Productivity** | Use proven building blocks instead of reinventing the wheel |
| **Maintainability** | Depend on stable base widgets, unaffected by internal changes |
| **Reusability** | One encapsulated component can be used everywhere |
| **Performance** | Built-in widgets are highly optimized |

> **Rule of thumb**: Over 90% of UI components (buttons, cards, form fields, list items) can be built entirely through composition. Custom painting (`CustomPaint`) is needed only for charts, diagrams, or unique visual elements.

## 6.2 Three Ways to Create Custom Components

| Approach | Use Case | Complexity |
| :--- | :--- | :--- |
| **Composition** | Most UI customizations | Low |
| **CustomPaint** | Charts, gauges, special graphics | Medium |
| **RenderObject** | Extreme performance or custom layout logic | High |

**Always prefer composition first.**

## 6.3 Practical Examples

### Example 1: Custom Button

```dart
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final double fontSize;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.color = Colors.blue,
    this.fontSize = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(label, style: TextStyle(fontSize: fontSize)),
    );
  }
}
```

### Example 2: Service Status Card (Complex Composition)

```dart
class ServiceStatusCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final String? description;
  final ServiceStatus status;
  final VoidCallback? onTap;

  const ServiceStatusCard({
    Key? key,
    required this.title,
    required this.iconData,
    this.description,
    this.status = ServiceStatus.running,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(iconData, size: 40),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    if (description != null)
                      Text(description!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Chip(
                label: Text(_statusLabel(status)),
                backgroundColor: _statusColor(status),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(ServiceStatus status) => status.toString().split('.').last;
  
  Color _statusColor(ServiceStatus status) {
    return switch (status) {
      ServiceStatus.running => Colors.green,
      ServiceStatus.stopped => Colors.red,
      ServiceStatus.paused => Colors.orange,
    };
  }
}

enum ServiceStatus { running, stopped, paused }
```

---
Previous: [Part 4 — Primitive UI components](part-4-primitive-components.md) · Next: [Part 6 — Naming conventions & best practices](part-6-naming-conventions.md)
