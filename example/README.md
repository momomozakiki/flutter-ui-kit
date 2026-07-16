---
title: Component Viewer (example app)
version: 1.1
last_validated: 2026-07-16
official: false
source: agent-generated
tags: [viewer, example, gallery, catalog]
applies_when: "Running or extending the flutter_ui_kit component viewer."
estimated_tokens: 400
---

# flutter_ui_kit — Component Viewer

A small Flutter app (**Windows desktop** + **web**) that renders a live gallery of
every `Ui*` component in this kit, themed with the kit's own `buildUiTheme()`. Use it
to eyeball components in light and dark, tune design tokens live via the app bar's
tuning button (dogfoods `UiTuningOverlay`), and recolor the whole app via the palette
button (dogfoods `UiThemePicker`).

The gallery ([`GalleryShell`](lib/gallery_shell.dart)) has a **manually toggleable side
nav** — the hamburger flips the rail between icon-only and icon+label — whose tabs are
the Atomic-Design tiers: **Atoms · Molecules · Organisms · Templates · Pages**. Pick a
tier to browse the components at that level; Templates and Pages show an explainer,
since those live in consuming apps rather than the shared kit.

## Run — Windows desktop (recommended)

```sh
cd example
flutter pub get
flutter run -d windows   # then: r = hot reload, R = hot restart
```

The window opens at **1280×800** — a 10″ tablet's landscape pixel size (set in
[`windows/runner/main.cpp`](windows/runner/main.cpp)) — and is resizable, so anything
you review here translates faithfully to a real tablet. Because it's `flutter run`, edits
appear on **hot reload with no Android APK rebuild/reinstall**. The kit renders the same
widget tree on desktop, web, and Android.

## Run — web

`flutter run -d chrome` is currently broken under this machine's puro setup (see
[`.ai/best_practices.md`](../.ai/best_practices.md)); to preview on web, build and serve
the static output:

```sh
cd example && flutter build web
cd build/web && python -m http.server 8080   # open http://localhost:8080
```

## How the gallery stays complete

The **Atoms** tier iterates the single shared registry
[`uiComponentCatalog`](../lib/src/catalog/ui_component_catalog.dart) exported from the
kit. **To surface a new atom in the viewer:**

1. Export it from the barrel `lib/flutter_ui_kit.dart` (already required for any new
   public component).
2. Add **one** `UiComponentDescriptor` entry to `uiComponentCatalog` — an `id`, `label`,
   `category`, and a `sample` builder returning a default instance.

It then appears here automatically — and, because the catalog lives in the kit, any
consuming app (e.g. a form designer's palette) can import the same list.

> The catalog test (`test/ui_component_catalog_test.dart` in the kit) builds every
> `sample`, so a broken entry fails CI rather than the viewer.

The **Molecules** and **Organisms** tiers are mapped **locally** in
[`lib/tier_registry.dart`](lib/tier_registry.dart) (the shared catalog is atoms-only),
with richer interactive demos in [`lib/component_demos.dart`](lib/component_demos.dart)
keyed by the same `id`.
