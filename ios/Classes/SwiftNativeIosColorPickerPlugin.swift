import Flutter
import UIKit

@available(iOS 14.0, *)
public class SwiftNativeIosColorPickerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "native_ios_color_picker", binaryMessenger: registrar.messenger())
        let instance = SwiftNativeIosColorPickerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showColorPicker":
            showColorPicker(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func showColorPicker(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
                result(FlutterError(code: "NO_VIEWCONTROLLER",
                                  message: "Could not get root view controller",
                                  details: nil))
                return
            }
            
            let colorPicker = UIColorPickerViewController()
            colorPicker.delegate = self
            self.flutterResult = result
            viewController.present(colorPicker, animated: true)
        }
    }
    
    private var flutterResult: FlutterResult?
}

@available(iOS 14.0, *)
extension SwiftNativeIosColorPickerPlugin: UIColorPickerViewControllerDelegate {
    public func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        let colorDict: [String: Any] = [
            "red": Double(color.components.red),
            "green": Double(color.components.green),
            "blue": Double(color.components.blue),
            "alpha": Double(color.components.alpha)
        ]
        flutterResult?(colorDict)
        flutterResult = nil
    }
    
    public func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        // Optional: Handle color selection changes in real-time
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