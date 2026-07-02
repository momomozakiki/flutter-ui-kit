import 'package:flutter/material.dart';

/// A single-line text input with an outline border and an optional [label] that
/// floats onto the border (the standard Material "outlined field" look).
///
/// Thin wrapper over [TextField] so every field in the app shares the same
/// border, density, and label behavior — use it for dense table cells too
/// (pass `label: null`) rather than reaching for a raw [TextField], so all
/// fields stay visually consistent. Set [width] to constrain it inside a
/// toolbar; leave it null to fill the available width.
class UiTextField extends StatelessWidget {
  const UiTextField({
    this.label,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
    this.enabled = true,
    this.isDense = true,
    this.width,
    this.floatingLabelAlways = false,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.style,
    this.obscureText = false,
    this.tooltip,
    this.suffixIcon,
    this.maxLines = 1,
    super.key,
  });

  /// Floating border label. `null` (e.g. for a dense table cell) shows no label.
  final String? label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (e.g. presses Enter) the field.
  final ValueChanged<String>? onSubmitted;
  final String? hintText;
  final bool enabled;
  final bool isDense;
  final double? width;

  /// When true, the label stays on the border even when empty/unfocused.
  final bool floatingLabelAlways;

  /// Optional focus node, so a parent can focus/refocus the field (e.g. a
  /// terminal that keeps the cursor in its command box for continuous entry).
  final FocusNode? focusNode;

  /// Request focus as soon as the field is shown.
  final bool autofocus;

  /// Display-only field (e.g. a live parsed value the user can copy but not edit).
  final bool readOnly;

  /// Horizontal alignment of the text (e.g. right-align a numeric value cell).
  final TextAlign textAlign;

  final TextInputType? keyboardType;

  /// Overrides the input text style (e.g. a compact/mono table cell).
  final TextStyle? style;

  /// Masks the text (e.g. a password / backup-passphrase field).
  final bool obscureText;

  /// Optional explanatory message shown on hover (desktop) / long-press (touch).
  final String? tooltip;

  /// Optional trailing widget inside the field (e.g. a clear ✕ button). Wired to
  /// [InputDecoration.suffixIcon]; leave null for no trailing affordance.
  final Widget? suffixIcon;

  /// Number of visible text lines (`1` = the default single-line field). Set >1
  /// for a multi-line text area (e.g. pasting several lines of sample data).
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final Widget field = TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      readOnly: readOnly,
      textAlign: textAlign,
      keyboardType: keyboardType,
      style: style,
      obscureText: obscureText,
      maxLines: maxLines,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        isDense: isDense,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        floatingLabelBehavior:
            floatingLabelAlways ? FloatingLabelBehavior.always : null,
      ),
    );
    final Widget sized =
        width == null ? field : SizedBox(width: width, child: field);
    if (tooltip == null || tooltip!.isEmpty) return sized;
    return Tooltip(
      message: tooltip!,
      triggerMode: TooltipTriggerMode.longPress,
      child: sized,
    );
  }
}
