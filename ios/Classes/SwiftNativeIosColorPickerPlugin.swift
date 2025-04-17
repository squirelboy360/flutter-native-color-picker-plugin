import Flutter
import UIKit

@available(iOS 14.0, *)
public class SwiftNativeIosColorPickerPlugin: NSObject, FlutterPlugin {
    private var eventSink: FlutterEventSink?
    private var flutterResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "native_ios_color_picker", binaryMessenger: registrar.messenger())
        let instance = SwiftNativeIosColorPickerPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        let eventChannel = FlutterEventChannel(name: "native_ios_color_picker/events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showColorPicker":
            showColorPicker()
            result(nil) // Picker is being shown, no immediate result
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func showColorPicker() {
        DispatchQueue.main.async {
            guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
                return
            }

            let colorPicker = UIColorPickerViewController()
            colorPicker.delegate = self
            viewController.present(colorPicker, animated: true)
        }
    }
}

@available(iOS 14.0, *)
extension SwiftNativeIosColorPickerPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

@available(iOS 14.0, *)
extension SwiftNativeIosColorPickerPlugin: UIColorPickerViewControllerDelegate {
    public func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        // Nothing to do – picker is dismissed, but live updates already sent via eventSink
    }

    public func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        guard let sink = eventSink else { return }

        let color = viewController.selectedColor
        let colorDict: [String: Any] = [
            "red": Double(color.components.red),
            "green": Double(color.components.green),
            "blue": Double(color.components.blue),
            "alpha": Double(color.components.alpha)
        ]

        sink(colorDict) // live send to Flutter
    }
}

extension UIColor {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}
