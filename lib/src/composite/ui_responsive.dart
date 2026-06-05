import 'package:flutter/widgets.dart';

import '../theme/ui_breakpoints.dart';

/// Signature for [UiResponsive.builder]: builds UI for the resolved
/// [UiDeviceClass].
typedef UiResponsiveBuilder = Widget Function(
  BuildContext context,
  UiDeviceClass deviceClass,
);

/// Rebuilds its subtree against the [UiDeviceClass] derived from the *available
/// width* (via [LayoutBuilder]), not the whole screen — so it composes when
/// embedded inside a pane.
///
/// Use it to switch a layout between, say, stacked (`compact`/`medium`) and
/// side-by-side (`expanded`/`large`).
///
/// ```dart
/// UiResponsive(
///   builder: (context, deviceClass) => switch (deviceClass) {
///     UiDeviceClass.compact || UiDeviceClass.medium => Column(children: panes),
///     _ => Row(children: panes),
///   },
/// );
/// ```
class UiResponsive extends StatelessWidget {
  const UiResponsive({required this.builder, super.key});

  final UiResponsiveBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return builder(context, UiBreakpoints.classify(width));
      },
    );
  }
}
