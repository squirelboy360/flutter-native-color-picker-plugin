import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_ios_color_picker/native_ios_color_picker.dart';

// Helper class for mocking the stream handler
class _TestMockStreamHandler implements MockStreamHandler {
  final StreamController<Map<dynamic, dynamic>> controller;

  _TestMockStreamHandler(this.controller);

  @override
  void onListen(dynamic arguments, MockStreamHandlerEventSink events) { // Correct sink type
    controller.stream.listen(events.success, onError: events.error, onDone: events.endOfStream);
  }

  @override
  dynamic onCancel(dynamic arguments) {
    // Handle cancellation if needed
    return null;
  }
}


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NativeIosColorPicker', () {
    const MethodChannel channel = MethodChannel('native_ios_color_picker');
    final List<MethodCall> log = <MethodCall>[];
    const EventChannel eventChannel = EventChannel('native_ios_color_picker/events');
    late StreamController<Map<dynamic, dynamic>> eventController;

    setUp(() {
      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          log.add(methodCall);
          // showColorPicker on the method channel doesn't return a value,
          // it triggers the native UI. Color updates come via the event channel.
          return null;
        },
      );

      // Mock the event channel
      eventController = StreamController<Map<dynamic, dynamic>>.broadcast();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(eventChannel, _TestMockStreamHandler(eventController)); // Use the helper class
    });

    tearDown(() {
      // Clean up method channel mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      log.clear();

      // Clean up event channel mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(eventChannel, null);
      eventController.close();
    });

    test('showColorPicker invokes the method channel', () async {
      // Call the method
      await NativeIosColorPicker.showColorPicker();

      // Verify the method was called on the channel
      expect(log, hasLength(1));
      expect(log.single.method, 'showColorPicker');
      // No need to check the result, as it's void/null
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

    test('onColorChanged receives color updates from event channel', () async {
      // Arrange: Define the expected color map
      final expectedColorMap = {
        'red': 0.1,
        'green': 0.2,
        'blue': 0.9,
        'alpha': 0.8,
      };

      // Act: Listen to the stream and emit a value from the mock controller
      final stream = NativeIosColorPicker.onColorChanged;
      final futureColor = stream.first; // Get the first event

      // Simulate native code sending an event
      eventController.add(expectedColorMap);

      // Assert: Check if the received color map matches the expected one
      final receivedColorMap = await futureColor;
      expect(receivedColorMap, equals(expectedColorMap));
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
