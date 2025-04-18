import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_ios_color_picker/native_ios_color_picker.dart';

// Helper class for mocking the stream handler
class _TestMockStreamHandler implements MockStreamHandler {
  final StreamController<Map<dynamic, dynamic>> controller;

  _TestMockStreamHandler(this.controller);

  @override
  void onListen(dynamic arguments, MockStreamHandlerEventSink events) {
    // Define a compatible error handler
    void handleError(Object error, [StackTrace? stackTrace]) {
      // Map the error to the structure expected by MockStreamHandlerEventSink.error
      // You might want to customize this based on expected error types
      final String errorCode = error is PlatformException ? error.code : 'STREAM_ERROR';
      final String? errorMessage = error is PlatformException ? error.message : error.toString();
      final dynamic errorDetails = error is PlatformException ? error.details : null;

      events.error(code: errorCode, message: errorMessage, details: errorDetails);
    }

    controller.stream.listen(
      events.success, // Pass data directly
      onError: handleError, // Use the compatible error handler
      onDone: events.endOfStream // Signal completion
    );
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

      // Define the expected Flutter Color object
      const expectedFlutterColor = Color.fromARGB(255, 128, 77, 179);

      // Compare the entire Color object
      expect(flutterColor, equals(expectedFlutterColor));
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
