import 'dart:async';
import 'package:flutter/services.dart';

class NativeIosColorPicker {
  static const MethodChannel _channel =
      MethodChannel('native_ios_color_picker');

  static const EventChannel _eventChannel =
      EventChannel('native_ios_color_picker/events');

  /// Shows the native macOS color picker window.
  /// Color changes are streamed via [onColorChanged].
  static Future<void> showColorPicker() async {
    try {
      await _channel.invokeMethod('showColorPicker');
    } on PlatformException catch (e) {
      throw 'Failed to show color picker: ${e.message}';
    }
  }

  /// Live stream of RGBA color updates from native macOS picker.
  static Stream<Map<dynamic, dynamic>> get onColorChanged {
    return _eventChannel.receiveBroadcastStream().cast<Map<dynamic, dynamic>>();
  }
}
