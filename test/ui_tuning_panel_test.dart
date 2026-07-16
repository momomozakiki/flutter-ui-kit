import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  // UiTuning.instance is a global singleton shared by every test in this file
  // (flutter test isolates the FILE, not each test) — reset before/after each.
  // The Copy-as-code path calls Clipboard.setData on SystemChannels.platform;
  // register a mock handler at file scope so it is active before any test runs,
  // and clear it in tearDown so it can't leak.
  final messenger =
      TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger;
  Object? clipboardText;

  setUp(() {
    clipboardText = null;
    UiTuning.instance.reset();
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboardText = (call.arguments as Map)['text'];
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    UiTuning.instance.reset();
  });

  // The panel is a ListView (~14 sliders + a button row); a tall surface makes
  // the whole list — including the Reset/Copy buttons at the bottom — build and
  // sit on-screen so they are findable and tappable without scrolling.
  Future<void> pumpTall(WidgetTester tester, Widget home) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(home);
  }

  Widget host() =>
      MaterialApp(theme: buildUiTheme(), home: const Scaffold(body: UiTuningPanel()));

  testWidgets('a slider writes back to its UiTuning setter', (tester) async {
    await pumpTall(tester, host());

    // The first slider is "Control height (shared default)" (range 24–60).
    final Slider slider = tester.widget<Slider>(find.byType(Slider).first);
    slider.onChanged!(44);
    await tester.pump();

    expect(UiTuning.instance.controlHeight, 44);
  });

  testWidgets('rebuilds its slider labels when UiTuning changes externally',
      (tester) async {
    await pumpTall(tester, host());
    expect(
      find.text('Control height (shared default): 35'),
      findsOneWidget,
    );

    UiTuning.instance.controlHeight = 50;
    await tester.pump();

    expect(
      find.text('Control height (shared default): 50'),
      findsOneWidget,
    );
    expect(
      find.text('Control height (shared default): 35'),
      findsNothing,
    );
  });

  testWidgets('Reset restores tuning to its seeded defaults', (tester) async {
    UiTuning.instance.controlHeight = 55;
    await pumpTall(tester, host());

    await tester.tap(find.widgetWithText(OutlinedButton, 'Reset'));
    await tester.pump();

    expect(UiTuning.instance.controlHeight, UiSizing.controlHeight);
  });

  testWidgets('Copy as code writes a snippet to the clipboard and shows a '
      'confirmation SnackBar', (tester) async {
    await pumpTall(tester, host());

    await tester.tap(find.widgetWithText(FilledButton, 'Copy as code'));
    await tester.pump();

    expect(clipboardText, isA<String>());
    expect((clipboardText! as String).isNotEmpty, isTrue);
    expect(find.text('Copied current values as code'), findsOneWidget);
  });
}
