import 'dart:async';
import 'package:flutter/services.dart';

class NativeIosColorPicker {
  static const MethodChannel _channel =
      MethodChannel('native_ios_color_picker');

  /// Shows the native iOS color picker and returns the selected color.
  ///
  /// Returns a [Map] containing the RGBA values of the selected color:
  /// - red: Double value between 0.0 and 1.0
  /// - green: Double value between 0.0 and 1.0
  /// - blue: Double value between 0.0 and 1.0
  /// - alpha: Double value between 0.0 and 1.0
  static Future<Map<String, double>> showColorPicker() async {
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('showColorPicker');
      return {
        'red': result['red'] as double,
        'green': result['green'] as double,
        'blue': result['blue'] as double,
        'alpha': result['alpha'] as double,
      };
    } on PlatformException catch (e) {
      throw 'Failed to show color picker: ${e.message}';
    }
  }
}
