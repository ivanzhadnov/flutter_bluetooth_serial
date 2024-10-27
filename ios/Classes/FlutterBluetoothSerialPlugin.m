import ExternalAccessory

public class SwiftFlutterBluetoothClassicPlugin: NSObject, FlutterPlugin {
var session: EASession?
var inputStream: InputStream?
var outputStream: OutputStream?

public static func register(with registrar: FlutterPluginRegistrar) {
let channel = FlutterMethodChannel(name: "flutter_bluetooth_classic", binaryMessenger: registrar.messenger())
let instance = SwiftFlutterBluetoothClassicPlugin()
registrar.addMethodCallDelegate(instance, channel: channel)
}

public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
if call.method == "connectToDevice" {
let args = call.arguments as? [String: String]
let deviceType = args?["deviceType"]
if deviceType == "XGPS160" {
connectToDevice(protocol: "com.dualav.xgps160", result: result)
} else if deviceType == "GLO" {
connectToDevice(protocol: "com.garmin.glo", result: result)
} else {
result(FlutterError(code: "INVALID_DEVICE", message: "Invalid device type specified", details: nil))
}
} else {
result(FlutterMethodNotImplemented)
}
}

private func connectToDevice(protocol: String, result: FlutterResult) {
let accessories = EAAccessoryManager.shared().connectedAccessories
guard let accessory = accessories.first(where: { $0.protocolStrings.contains(`protocol`) }) else {
result(FlutterError(code: "NO_DEVICE", message: "\(protocol) device not found", details: nil))
return
}

session = EASession(accessory: accessory, forProtocol: `protocol`)
inputStream = session?.inputStream
        outputStream = session?.outputStream
        inputStream?.delegate = self
inputStream?.schedule(in: .current, forMode: .default)
inputStream?.open()
outputStream?.open()

result("Connected to \(protocol) device")
}
}

extension SwiftFlutterBluetoothClassicPlugin: StreamDelegate {
public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
if eventCode == .hasBytesAvailable, let inputStream = aStream as? InputStream {
var buffer = [UInt8](repeating: 0, count: 1024)
let bytesRead = inputStream.read(&buffer, maxLength: buffer.count)
if bytesRead > 0 {
let output = String(bytes: buffer, encoding: .utf8) ?? "Invalid data"
print("Received data: \(output)")
// Optional: Send data back to Flutter via EventChannel
}
}
}
}