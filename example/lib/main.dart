import 'package:flutter/material.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

import 'gallery_shell.dart';

void main() => runApp(const ViewerApp());

/// The flutter_ui_kit component viewer.
///
/// A `MaterialApp` themed with the kit's own [buildUiTheme]. Both the color
/// seed and the light / dark / system mode come from [UiThemeController] — the
/// same runtime theme-selection mechanism a consuming app uses. Wrapping the
/// app in a `ListenableBuilder` on that singleton means picking a color or
/// appearance in `UiThemePicker` recolors the whole viewer live.
class ViewerApp extends StatelessWidget {
  const ViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final UiThemeController controller = UiThemeController.instance;
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, _) {
        return MaterialApp(
          title: 'flutter_ui_kit viewer',
          debugShowCheckedModeBanner: false,
          theme: buildUiTheme(brightness: Brightness.light, seed: controller.seed),
          darkTheme:
              buildUiTheme(brightness: Brightness.dark, seed: controller.seed),
          themeMode: controller.themeMode,
          home: const GalleryShell(),
        );
      },
    );
  }
}
