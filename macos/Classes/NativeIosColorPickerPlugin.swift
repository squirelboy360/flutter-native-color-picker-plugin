import FlutterMacOS
import AppKit

@available(macOS 10.15, *)
public class NativeIosColorPickerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "native_ios_color_picker", binaryMessenger: registrar.messenger)
        let instance = NativeIosColorPickerPlugin()
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
            let colorPanel = NSColorPanel.shared
            colorPanel.setTarget(self)
            colorPanel.setAction(#selector(self.colorChanged(_:)))
            colorPanel.makeKeyAndOrderFront(nil)
            self.flutterResult = result
        }
    }
    
    private var flutterResult: FlutterResult?
    
    @objc private func colorChanged(_ sender: NSColorPanel) {
        guard let color = sender.color.usingColorSpace(.deviceRGB) else { return }
        
        let colorDict: [String: Any] = [
            "red": color.redComponent,
            "green": color.greenComponent,
            "blue": color.blueComponent,
            "alpha": color.alphaComponent
        ]
        
        flutterResult?(colorDict)
        flutterResult = nil
        sender.close()
    }
}