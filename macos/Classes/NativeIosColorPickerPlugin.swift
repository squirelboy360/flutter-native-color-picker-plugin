import FlutterMacOS
import AppKit

@available(macOS 10.15, *)
public class NativeIosColorPickerPlugin: NSObject, FlutterPlugin {
    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        // Method channel (still required for triggering picker)
        let methodChannel = FlutterMethodChannel(name: "native_ios_color_picker", binaryMessenger: registrar.messenger)
        let instance = NativeIosColorPickerPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        // Event channel (for continuous color updates)
        let eventChannel = FlutterEventChannel(name: "native_ios_color_picker/events", binaryMessenger: registrar.messenger)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showColorPicker":
            showColorPicker()
            result(nil) // acknowledge method call
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func showColorPicker() {
        DispatchQueue.main.async {
            let colorPanel = NSColorPanel.shared
            colorPanel.setTarget(self)
            colorPanel.setAction(#selector(self.colorChanged(_:)))
            colorPanel.makeKeyAndOrderFront(nil)
        }
    }

    @objc private func colorChanged(_ sender: NSColorPanel) {
        guard let sink = eventSink else { return }
        guard let color = sender.color.usingColorSpace(.deviceRGB) else { return }

        let colorDict: [String: Any] = [
            "red": color.redComponent,
            "green": color.greenComponent,
            "blue": color.blueComponent,
            "alpha": color.alphaComponent
        ]

        sink(colorDict)
    }
}

@available(macOS 10.15, *)
extension NativeIosColorPickerPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}