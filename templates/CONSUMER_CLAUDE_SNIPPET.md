# Consuming the flutter_ui_kit design system

`flutter_ui_kit` is your app's **canonical Flutter design system**: shared design tokens (color, spacing, sizing, radius, typography), tablet-first breakpoints, and core/atom widgets (button, text field, dropdown, status chip, banner, checkbox). It lives in a separate repository and is consumed via a pinned git dependency. This keeps every app using the kit visually and structurally consistent.

## Adding the dependency

Pin the kit to a **released semantic-version tag** — never `ref: main`:

```yaml
dependencies:
  flutter_ui_kit:
    git:
      url: https://github.com/momomozakiki/flutter-ui-kit.git
      ref: v0.1.0
```

Replace `v0.1.0` with the latest tag from [the kit's releases](https://github.com/momomozakiki/flutter-ui-kit/releases).

## Local development (optional)

When actively iterating on both this app and the kit at once, use a local override instead of re-tagging on every change. Add this to your `pubspec.yaml`:

```yaml
dependency_overrides:
  flutter_ui_kit:
    path: ../flutter-ui-kit   # local sibling clone; remove before committing/releasing this app
```

**Important:** remove the override before committing — it must never ship in a released version of this app.

## Repo separation rules

The kit lives in a separate repository. Follow these rules to keep the boundary clear:

- **Never edit the kit from this app's session.** If you need to change a kit component or token, open the kit repo separately and make the change there; then bump the pinned `ref:` in this app's `pubspec.yaml`.
- **Never locally shadow or fork a kit component.** If a `Ui<Name>` component needs different behavior, either use one of its optional constructor overrides (see below) or propose the change in the kit repo. Two parallel implementations of the same component is a bug, not a feature.
- **Ask before modifying if ambiguous.** If a UI request could plausibly target either this app or the kit (e.g., "change the dropdown look"), ask the user which repo it targets before making changes.

## Component behavior: defaults with optional overrides

Every tunable value in a kit component ships with a sensible default. Per-instance overrides are optional named constructor parameters — `null` means "inherit the app-wide theme default". Existing call sites are unaffected when a new override is added.

Example with `UiButton`:

```dart
// Uses the shared theme default height
UiButton(label: 'Save', onPressed: onSave)

// Overrides just this instance's height
UiButton(label: 'Save', onPressed: onSave, height: 48)
```

If you want a different default app-wide (not just for one instance), that's a kit-level tuning change via the `UiTuning` debug-only live tuning system — refer to the kit's own `Documentations/design-system-contract.md` for the full mechanism.

## Optional: Debug-only live tuning panel

The kit's theme system works with zero setup — every tunable token is seeded from consts, so defaults work out of the box. However, if this app wants to experiment with live theme adjustments during development, the kit provides an optional `UiTuningOverlay` (a non-modal floating panel).

To enable it, wire `UiTuningOverlay` into your widget tree alongside your root `MaterialApp`. See the kit's `README.md` and `Documentations/design-system-contract.md` for detailed setup instructions.

## Suggested folder layout

```
{{CONSUMING_PACKAGE}}/
├── lib/
│   ├── src/
│   │   └── composite/    # app-specific screens/layouts built from kit components
│   └── main.dart
└── .claude/skills/
    └── {{APP_NAME}}-ui-component/SKILL.md
```

Use the `templates/app-ui-component.SKILL.md.template` from this kit as a starter for your own `.claude/skills/{{APP_NAME}}-ui-component/SKILL.md`, filling in the placeholders to describe your app's UI conventions.
