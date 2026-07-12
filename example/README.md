---
title: Component Viewer (example app)
version: 1.0
last_validated: 2026-07-12
official: false
source: agent-generated
tags: [viewer, example, gallery, catalog]
applies_when: "Running or extending the flutter_ui_kit component viewer."
estimated_tokens: 300
---

# flutter_ui_kit — Component Viewer

A small Flutter **web** app that renders a live gallery of every `Ui*` component
in this kit, themed with the kit's own `buildUiTheme()`. Use it to eyeball
components in light and dark, and to tune design tokens live via the app bar's
tuning button (dogfoods `UiTuningOverlay`).

## Run

```sh
cd example
flutter pub get
flutter run -d chrome
```

The kit renders the same widget tree on web and desktop, so the web preview is
faithful to how a consuming app will look.

## How the gallery stays complete

The gallery iterates the single shared registry
[`uiComponentCatalog`](../lib/src/catalog/ui_component_catalog.dart) exported from
the kit. **To surface a new component in the viewer:**

1. Export it from the barrel `lib/flutter_ui_kit.dart` (already required for any
   new public component).
2. Add **one** `UiComponentDescriptor` entry to `uiComponentCatalog` — an `id`,
   `label`, `category`, and a `sample` builder returning a default instance.

It then appears here automatically — and, because the catalog lives in the kit,
any consuming app (e.g. a form designer's palette) can import the same list.

> The catalog test (`test/ui_component_catalog_test.dart` in the kit) builds
> every `sample`, so a broken entry fails CI rather than the viewer.
