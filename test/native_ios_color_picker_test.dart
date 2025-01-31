import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_ios_color_picker/native_ios_color_picker.dart';
import 'package:native_ios_color_picker/src/color_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NativeIosColorPicker', () {
    const MethodChannel channel = MethodChannel('native_ios_color_picker');
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return {'red': 0.5, 'green': 0.3, 'blue': 0.7, 'alpha': 1.0};
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      log.clear();
    });

    test('showColorPicker returns color values', () async {
      final result = await NativeIosColorPicker.showColorPicker();

      expect(log, hasLength(1));
      expect(log.single.method, 'showColorPicker');

      expect(result['red'], 0.5);
      expect(result['green'], 0.3);
      expect(result['blue'], 0.7);
      expect(result['alpha'], 1.0);
    });

    test('showColorPicker throws on platform exception', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          throw PlatformException(
            code: 'NO_VIEWCONTROLLER',
            message: 'Could not get root view controller',
          );
        },
      );

      expect(
        () => NativeIosColorPicker.showColorPicker(),
        throwsA(isA<String>().having(
          (String error) => error,
          'error message',
          contains('Could not get root view controller'),
        )),
      );
    });
  });

  group('ColorModel', () {
    test('creates from map correctly', () {
      final map = {
        'red': 0.5,
        'green': 0.3,
        'blue': 0.7,
        'alpha': 1.0,
      };

      final color = ColorModel.fromMap(map);

      expect(color.red, 0.5);
      expect(color.green, 0.3);
      expect(color.blue, 0.7);
      expect(color.alpha, 1.0);
    });

    test('converts to Color correctly', () {
      final color = ColorModel(
        red: 0.5,
        green: 0.3,
        blue: 0.7,
        alpha: 1.0,
      );

      final flutterColor = color.toColor();

      expect(flutterColor.red, 128); // 0.5 * 255 = 127.5 ≈ 128
      expect(flutterColor.green, 77); // 0.3 * 255 = 76.5 ≈ 77
      expect(flutterColor.blue, 179); // 0.7 * 255 = 178.5 ≈ 179
      expect(flutterColor.alpha, 255); // 1.0 * 255 = 255
    });

    test('converts to map correctly', () {
      final color = ColorModel(
        red: 0.5,
        green: 0.3,
        blue: 0.7,
        alpha: 1.0,
      );

      final map = color.toMap();

      expect(map['red'], 0.5);
      expect(map['green'], 0.3);
      expect(map['blue'], 0.7);
      expect(map['alpha'], 1.0);
    });
  });
}
