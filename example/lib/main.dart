import 'package:flutter/material.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

import 'gallery_screen.dart';

void main() => runApp(const ViewerApp());

/// The flutter_ui_kit component viewer.
///
/// A `MaterialApp` themed with the kit's own [buildUiTheme] so every component
/// renders exactly as a consuming app would see it. The brightness is held in
/// local state and flipped from the gallery's app bar.
class ViewerApp extends StatefulWidget {
  const ViewerApp({super.key});

  @override
  State<ViewerApp> createState() => _ViewerAppState();
}

class _ViewerAppState extends State<ViewerApp> {
  Brightness _brightness = Brightness.light;

  void _toggleBrightness() => setState(() {
        _brightness = _brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_ui_kit viewer',
      debugShowCheckedModeBanner: false,
      theme: buildUiTheme(brightness: _brightness),
      home: GalleryScreen(
        brightness: _brightness,
        onToggleBrightness: _toggleBrightness,
      ),
    );
  }
}
