import 'package:flutter/material.dart';

/// A single-line text input with an outline border and a [label] that floats
/// onto the border (the standard Material "outlined field" look).
///
/// Thin wrapper over [TextField] so every field in the app shares the same
/// border, density, and label behavior. Set [width] to constrain it inside a
/// toolbar; leave it null to fill the available width.
class UiTextField extends StatelessWidget {
  const UiTextField({
    required this.label,
    this.controller,
    this.onChanged,
    this.hintText,
    this.enabled = true,
    this.isDense = true,
    this.width,
    this.floatingLabelAlways = false,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final bool enabled;
  final bool isDense;
  final double? width;

  /// When true, the label stays on the border even when empty/unfocused.
  final bool floatingLabelAlways;

  @override
  Widget build(BuildContext context) {
    final Widget field = TextField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        isDense: isDense,
        border: const OutlineInputBorder(),
        floatingLabelBehavior:
            floatingLabelAlways ? FloatingLabelBehavior.always : null,
      ),
    );
    return width == null ? field : SizedBox(width: width, child: field);
  }
}
