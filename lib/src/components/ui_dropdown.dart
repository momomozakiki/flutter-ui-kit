import 'package:flutter/material.dart';

/// One selectable entry in a [UiDropdown].
@immutable
class UiDropdownItem<T> {
  const UiDropdownItem({required this.value, required this.label});

  final T value;
  final String label;
}

/// A dropdown whose [label] sits on/notches the top of an outline border — the
/// "Font ▾" toolbar look. Wraps [DropdownButtonFormField] so the label, border,
/// and density match [UiTextField].
///
/// The label always floats (the field generally has a value), matching a
/// settings-toolbar style. Pass `enabled: false` or `onChanged: null` to
/// disable.
class UiDropdown<T> extends StatelessWidget {
  const UiDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isDense = true,
    this.enabled = true,
    this.width,
    super.key,
  });

  final String label;
  final T? value;
  final List<UiDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isDense;
  final bool enabled;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final Widget field = DropdownButtonFormField<T>(
      initialValue: value,
      isDense: isDense,
      // Let the selected item take the available width (and ellipsize) so a
      // narrow, fixed-[width] dropdown never overflows its row by a few pixels.
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: isDense,
        border: const OutlineInputBorder(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      items: items
          .map((UiDropdownItem<T> it) =>
              DropdownMenuItem<T>(value: it.value, child: Text(it.label)))
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
    return width == null ? field : SizedBox(width: width, child: field);
  }
}
