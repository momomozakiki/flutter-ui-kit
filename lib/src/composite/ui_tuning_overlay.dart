import 'package:flutter/material.dart';

import 'ui_tuning_panel.dart';

/// Toggles a movable, non-modal floating `UiTuningPanel` on top of the app —
/// unlike a `Drawer`, there is no modal barrier, so the app underneath stays
/// fully visible and interactive while tuning. Debug-only; call from behind a
/// `kDebugMode` gate.
class UiTuningOverlay {
  UiTuningOverlay._();

  static OverlayEntry? _entry;

  /// True while the floating panel is currently shown.
  static bool get isShown => _entry != null;

  /// Shows the panel if hidden, hides it if shown.
  static void toggle(BuildContext context) {
    if (_entry != null) {
      hide();
    } else {
      show(context);
    }
  }

  static void show(BuildContext context) {
    if (_entry != null) return;
    final overlay = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(
      builder: (context) => const _FloatingTuningPanel(),
    );
    overlay.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}

class _FloatingTuningPanel extends StatefulWidget {
  const _FloatingTuningPanel();

  @override
  State<_FloatingTuningPanel> createState() => _FloatingTuningPanelState();
}

class _FloatingTuningPanelState extends State<_FloatingTuningPanel> {
  static const double _width = 340;
  static const double _height = 560;

  Offset? _position;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    // Default position: top-right corner, inset from the edges. Computed once
    // (on first build) then held in local state so dragging doesn't fight the
    // default every rebuild (e.g. when a slider drag rebuilds this subtree).
    _position ??= Offset(screen.width - _width - 16, 56);

    return Positioned(
      left: _position!.dx,
      top: _position!.dy,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: _width,
          height: _height,
          child: Column(
            children: [
              // Drag handle: title + close button. GestureDetector (not the
              // whole panel) owns the drag so sliders below stay interactive.
              GestureDetector(
                onPanUpdate: (details) => setState(() {
                  _position = _position! + details.delta;
                }),
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.drag_indicator, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Design Tuning (debug only)',
                            style: Theme.of(context).textTheme.titleSmall),
                      ),
                      const IconButton(
                        icon: Icon(Icons.close),
                        tooltip: 'Close',
                        iconSize: 18,
                        onPressed: UiTuningOverlay.hide,
                      ),
                    ],
                  ),
                ),
              ),
              const Expanded(child: UiTuningPanel()),
            ],
          ),
        ),
      ),
    );
  }
}
