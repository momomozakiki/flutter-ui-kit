# Naming Conventions (living document)

Per-language and per-artifact naming rules for **flutter-ui-kit**. Append when a new
convention is agreed. Match the code that already follows these rather than inventing
new terms.

## Dart / Flutter

- `lowerCamelCase` for members (fields, methods, locals, parameters).
- `PascalCase` for types (classes, enums, extensions, typedefs, mixins).
- `snake_case` for file names.
- Private/internal identifiers prefixed with a single leading underscore (`_helper`).
- `UPPER_SNAKE_CASE` is **not** used for Dart constants — use `lowerCamelCase`
  (e.g. `defaultButtonHeight`), matching effective-Dart.

## Kit-specific component & token naming

- **Components** are `Ui<Name>`, one widget per file, file named `ui_<name>.dart`
  under `lib/src/components/` (e.g. `UiButton` → `ui_button.dart`). Their tests
  mirror the name: `test/ui_<name>_test.dart`.
- **Token classes** live in `lib/src/theme/` as `Ui<Category>` with `static const`
  members: `UiSpacing`, `UiSizing`, `UiRadius`, `UiTypography`, `UiColors`,
  `UiBreakpoints` (plus `UiTheme`, `UiTuning`).
- **Composites** (generic, project-agnostic) are `Ui<Name>` under
  `lib/src/composite/` (e.g. `UiResponsive`, `UiTuningPanel`).
- **Enums carry behavior via extensions** where useful (`<Enum>X`), e.g. a role or
  variant enum extended with helper getters.

## Files & directories

- Project files and packages: `snake_case`; configs, docs, and skills: `kebab-case`.
- Claude Code skills: the directory is `kebab-case` and the `name:` frontmatter
  field equals the directory name.

## Workflow artifacts

- Archived plans: `plans/archive/YYYY-MM-DD_<slug>/` where `<slug>` is a short
  `kebab-case` task descriptor (e.g. `2026-07-10_ui-status-chip-test`).
- The active plan is always `plans/UNFINISHED.md` (exactly one at a time; absent
  when no work is in progress).
- Change-history ledger: one file per ISO week, `history/YYYY-Www.md` (e.g.
  `history/2026-W28.md`; `Www` = `date +%G-W%V`). Within a week file, days are
  `## YYYY-MM-DD` headings and each substantial change is a `### [tag] <path-or-area>`
  subheading (tags: `[design] [doc] [code] [workflow] [config] [decision] [data]`);
  minor changes are a single bullet line under the day. Format spec: `history/FORMAT.md`.
