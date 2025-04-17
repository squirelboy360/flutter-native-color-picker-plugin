## 0.0.2

*   **BREAKING CHANGE:** Refactored the plugin to use an `EventChannel` for color updates.
    *   `NativeIosColorPicker.showColorPicker()` is now `Future<void>` and only shows the picker.
    *   Added `NativeIosColorPicker.onColorChanged` stream (`Stream<Map<dynamic, dynamic>>`) which emits color updates (RGBA map) from the native picker in real-time.
*   Fixed an issue where the picker might disappear immediately after selection by adopting a stream-based approach for color updates.
*   Updated `README.md` with new usage instructions and API details reflecting the stream-based approach.
*   Improved `ColorModel.fromMap` to handle dynamic map types safely from the stream.


## 0.0.1

* Initial release.
