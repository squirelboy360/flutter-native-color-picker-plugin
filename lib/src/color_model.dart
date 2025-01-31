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

  /// Creates a [ColorModel] from a map containing RGBA values.
  factory ColorModel.fromMap(Map<String, double> map) {
    return ColorModel(
      red: map['red'] ?? 0.0,
      green: map['green'] ?? 0.0,
      blue: map['blue'] ?? 0.0,
      alpha: map['alpha'] ?? 1.0,
    );
  }

  /// Converts the color model to a Flutter [Color].
  Color toColor() {
    return Color.fromRGBO(
      (red * 255).round(),
      (green * 255).round(),
      (blue * 255).round(),
      alpha,
    );
  }

  /// Converts the color model to a map representation.
  Map<String, double> toMap() {
    return {
      'red': red,
      'green': green,
      'blue': blue,
      'alpha': alpha,
    };
  }
}
