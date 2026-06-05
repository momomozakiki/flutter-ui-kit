import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  group('UiBreakpoints.classify', () {
    test('classifies each band by its lower boundary', () {
      expect(UiBreakpoints.classify(599), UiDeviceClass.compact);
      expect(UiBreakpoints.classify(600), UiDeviceClass.medium); // 7" portrait
      expect(UiBreakpoints.classify(839), UiDeviceClass.medium);
      expect(UiBreakpoints.classify(840), UiDeviceClass.expanded);
      expect(UiBreakpoints.classify(1199), UiDeviceClass.expanded);
      expect(UiBreakpoints.classify(1200), UiDeviceClass.large);
    });

    test('the 10" desktop default (1280) is large', () {
      expect(UiBreakpoints.classify(1280), UiDeviceClass.large);
    });

    test('the 7" floor (960) is expanded in landscape', () {
      expect(UiBreakpoints.classify(960), UiDeviceClass.expanded);
    });
  });
}
