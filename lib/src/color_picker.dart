import 'dart:async';
import 'package:flutter/services.dart';

class NativeIosColorPicker {
  static const MethodChannel _channel =
      MethodChannel('native_ios_color_picker');

  static const EventChannel _eventChannel =
      EventChannel('native_ios_color_picker/events');

  static Stream<Map<dynamic, dynamic>>? _sharedStream;

  static Future<void> showColorPicker() async {
    try {
      await _channel.invokeMethod('showColorPicker');
    } on PlatformException catch (e) {
      throw 'Failed to show color picker: ${e.message}';
    }
  }

  static Stream<Map<dynamic, dynamic>> get onColorChanged {
    _sharedStream ??= _eventChannel.receiveBroadcastStream().cast<Map<dynamic, dynamic>>();
    return _sharedStream!;
  }
}