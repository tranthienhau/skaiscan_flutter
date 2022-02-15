import Flutter
import UIKit

public class SwiftSkaiscanFfiPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "skaiscan_ffi", binaryMessenger: registrar.messenger())
    let instance = SwiftSkaiscanFfiPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
