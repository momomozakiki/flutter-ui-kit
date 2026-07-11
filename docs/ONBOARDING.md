---
title: "Onboarding: Adding flutter_ui_kit to a new Flutter app"
version: 1.0
last_validated: 2026-07-11
official: false
source: agent-generated
tags: [onboarding, consumer-setup, pubspec, git-dependency]
applies_when: "Setting up a new Flutter app to consume flutter_ui_kit as a pinned git dependency."
estimated_tokens: 1200
---

# Onboarding: Adding flutter_ui_kit to a new Flutter app
**Version 1.0** — *step-by-step setup for a consuming app.*

## Revision History
| Version | Date       | Change   |
|---------|------------|----------|
| 1.0     | 2026-07-11 | Added Documentation Standard frontmatter. |

Follow these steps in order to set up a brand-new Flutter app to use `flutter_ui_kit`.

1. **Add the git dependency to `pubspec.yaml`**, pinned to the latest released tag (never `ref: main`):

   ```yaml
   dependencies:
     flutter_ui_kit:
       git:
         url: https://github.com/momomozakiki/flutter-ui-kit.git
         ref: v0.1.0  # replace with the latest tag
   ```

2. **Copy `templates/analysis_options.yaml`** from this kit into the root of your new package:

   ```bash
   cp templates/analysis_options.yaml path/to/your-app/analysis_options.yaml
   ```

3. **Copy the CLAUDE.md snippet** from `templates/CONSUMER_CLAUDE_SNIPPET.md` into your app's own `CLAUDE.md`:

   - Create or open `.../your-app/CLAUDE.md`.
   - Paste the content from `templates/CONSUMER_CLAUDE_SNIPPET.md`.
   - Replace all `{{PLACEHOLDER}}` tokens (e.g., `{{APP_NAME}}`, `{{CONSUMING_PACKAGE}}`) with your app's actual names.

4. **Set up a kit-specific Claude Code skill** for your app:

   - Copy `templates/app-ui-component.SKILL.md.template` to `.claude/skills/{{APP_NAME}}-ui-component/SKILL.md` in your app's repo.
   - Replace all `{{APP_NAME}}` and `{{CONSUMING_PACKAGE}}` placeholders with your app's actual names.
   - This skill documents your app's UI conventions and how to interact with the kit.

5. **Verify the kit resolves cleanly:**

   ```bash
   flutter pub get
   flutter analyze
   flutter test
   ```

   All three should pass with no errors.

6. **Use the kit's theme in your app**, applying it to your `MaterialApp`:

   ```dart
   import 'package:flutter_ui_kit/flutter_ui_kit.dart';

   void main() {
     runApp(const MyApp());
   }

   class MyApp extends StatelessWidget {
     const MyApp({super.key});

     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         title: 'My App',
         theme: buildUiTheme(seed: Colors.blue), // use the kit's theme
         home: const MyHomePage(),
       );
     }
   }
   ```

7. **Verify theme rendering** before building further:

   - Render a default `UiButton` (from the kit) or check this kit's own demo output.
   - Confirm it looks as expected — button color, text styling, size, padding, etc.
   - This early check catches a missing or misapplied theme before you've built a lot of UI on top of broken defaults.

**You're ready to build.** Import kit components from `package:flutter_ui_kit/flutter_ui_kit.dart` and tokens from the `flutter_ui_kit` namespace in your composites. See `README.md` and `docs/design-system-contract.md` for the full component and token catalog.
