# Native iOS Color Picker

A Flutter plugin that provides a native iOS color picker interface using the UIColorPickerViewController available in iOS 14 and above.

## Features

- Native iOS/macOS color picker UI (macOS implementation might need verification based on provided code)
- Streams RGBA color values in real-time from the picker
- Supports iOS 14+ and potentially macOS 10.15+ (requires native implementation verification)
- Simple API using MethodChannel for showing the picker and EventChannel for color updates

## Requirements

- iOS 14.0 or higher
- Flutter 2.0.0 or higher

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  native_ios_color_picker: ^0.0.2
```

Then run:

```bash
$ flutter pub get
```

## Usage

First, import the package:

```dart
import 'dart:async'; // Required for StreamSubscription
import 'package:flutter/material.dart'; // Required for Color
import 'package:native_ios_color_picker/native_ios_color_picker.dart';
```

The color picker is shown using `NativeIosColorPicker.showColorPicker()`. Color changes are received via the `NativeIosColorPicker.onColorChanged` stream. You need to subscribe to this stream to get color updates.

```dart
StreamSubscription? _colorSubscription;
Color _selectedColor = Colors.blue; // Initial color

@override
void initState() {
  super.initState();
  // Subscribe to the color changes stream
  _colorSubscription = NativeIosColorPicker.onColorChanged.listen((colorMap) {
    // The stream emits a Map<dynamic, dynamic>, convert it safely
    // You can use the ColorModel for conversion (see below)
    final newColor = Color.fromRGBO(
      ((colorMap['red'] ?? 0.0) * 255).toInt(),
      ((colorMap['green'] ?? 0.0) * 255).toInt(),
      ((colorMap['blue'] ?? 0.0) * 255).toInt(),
      (colorMap['alpha'] ?? 1.0),
    );
    setState(() {
      _selectedColor = newColor;
    });
    print('Color updated: $_selectedColor');
  }, onError: (error) {
    print('Error receiving color: $error');
  });
}

@override
void dispose() {
  // Cancel the subscription when the widget is disposed
  _colorSubscription?.cancel();
  super.dispose();
}

// Somewhere in your widget build method or an event handler:
void _openColorPicker() async {
  try {
    // Show the picker. It doesn't return the color directly anymore.
    await NativeIosColorPicker.showColorPicker();
  } catch (e) {
    print('Error showing color picker: $e');
  }
}

// Example button to open the picker
ElevatedButton(
  onPressed: _openColorPicker,
  child: Text('Show Color Picker'),
  style: ElevatedButton.styleFrom(backgroundColor: _selectedColor),
)

```

### Using with ColorModel

The `ColorModel` class can simplify handling the map received from the stream:

```dart
// Inside the stream listener:
_colorSubscription = NativeIosColorPicker.onColorChanged.listen((colorMap) {
  // Ensure the map has the correct types before passing to fromMap
  final safeMap = Map<String, dynamic>.from(colorMap);
  final colorModel = ColorModel.fromMap(safeMap);
  final newColor = colorModel.toColor();

  setState(() {
    _selectedColor = newColor;
  });

  // Access individual components
  print('Red: ${colorModel.red}');
  print('Green: ${colorModel.green}');
  // ... etc.
}, onError: // ...
);
```

### Screenshots

<img src="https://github.com/squirelboy360/flutter-native-color-picker-plugin/blob/main/assets/iphone.png" width="300" alt="iOS Color Picker"/>

<img src="https://github.com/squirelboy360/flutter-native-color-picker-plugin/blob/main/assets/macos.png" width="300" alt="macOS Color Picker"/>

## API Reference

### NativeIosColorPicker

#### `static Future<void> showColorPicker()`

Shows the native iOS/macOS color picker window. This method does not return the selected color directly. Color updates are sent via the `onColorChanged` stream.

#### `static Stream<Map<dynamic, dynamic>> get onColorChanged`

A broadcast stream that emits updates when the color is changed in the native picker. Each event is a `Map` containing RGBA components (keys: 'red', 'green', 'blue', 'alpha') with values between 0.0 and 1.0. You should subscribe to this stream to receive color updates.

### ColorModel

#### `ColorModel({required double red, required double green, required double blue, required double alpha})`

Creates a new ColorModel instance with the specified RGBA values (between 0.0 and 1.0).

#### `ColorModel.fromMap(Map<String, dynamic> map)`

Creates a ColorModel instance from a map containing RGBA values (typically received from the `onColorChanged` stream). Handles potential null values and converts numeric types safely.

#### `Color toColor()`

Converts the ColorModel to a Flutter Color object.

#### `Map<String, double> toMap()`

Converts the ColorModel to a map containing RGBA values.

## Platform Support

| Platform | Support |
|----------|----------|
| iOS      | iOS 14+  |
| macOS    | 10.15+   |
| Android  | ❌       |
| Web      | ❌       |
| Windows  | ❌       |
| Linux    | ❌       |

## Contributing

Contributions are welcome! If you find a bug or want to add a feature, please feel free to create an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
