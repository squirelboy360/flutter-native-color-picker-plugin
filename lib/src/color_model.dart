import 'dart:ui' show Color;

class ColorModel {
  final double red;
  final double green;
  final double blue;
  final double alpha;

  const ColorModel({
    required this.red,
    required this.green,
    required this.blue,
    this.alpha = 1.0,
  });

  /// Tworzy ColorModel z mapy, niezależnie od typu dynamicznego.
  factory ColorModel.fromMap(Map<String, dynamic> map) {
    return ColorModel(
      red: (map['red'] ?? 0.0).toDouble(),
      green: (map['green'] ?? 0.0).toDouble(),
      blue: (map['blue'] ?? 0.0).toDouble(),
      alpha: (map['alpha'] ?? 1.0).toDouble(),
    );
  }

  /// Konwertuje model na Flutterowy Color.
  Color toColor() {
    return Color.fromRGBO(
      (red * 255).round(),
      (green * 255).round(),
      (blue * 255).round(),
      alpha,
    );
  }

  /// Konwertuje model z powrotem na mapę.
  Map<String, double> toMap() {
    return {
      'red': red,
      'green': green,
      'blue': blue,
      'alpha': alpha,
    };
  }
}