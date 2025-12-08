import Flutter
import UIKit

public class DeviceCapabilityPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "device_capability", binaryMessenger: registrar.messenger())
    let instance = DeviceCapabilityPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getDeviceInfo":
      do {
        let deviceInfo = collectDeviceInfo()
        result(deviceInfo)
      } catch {
        result(FlutterError(code: "ERROR", message: "Failed to collect device info: \(error.localizedDescription)", details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func collectDeviceInfo() -> [String: Any?] {
    let totalRam = ProcessInfo.processInfo.physicalMemory
    let usedRam = getUsedMemory()
    let (totalStorage, freeStorage) = getStorageInfo()
    let thermalState = getThermalState()
    let batteryInfo = getBatteryInfo()
    let screenInfo = getScreenInfo()
    let cpuCount = ProcessInfo.processInfo.processorCount
    
    return [
      "platform": "ios",
      "cpuCores": cpuCount,
      "totalRamBytes": Int64(totalRam),
      "usedRamBytes": Int64(usedRam),
      "totalStorageBytes": totalStorage,
      "freeStorageBytes": freeStorage,
      "sdkLevel": nil,
      "deviceModel": getDeviceModel(),
      "thermalState": thermalState,
      "lowPowerModeEnabled": ProcessInfo.processInfo.isLowPowerModeEnabled,
      "batteryLevel": batteryInfo.level,
      "isCharging": batteryInfo.isCharging,
      "screenWidth": screenInfo.width,
      "screenHeight": screenInfo.height,
      "screenDensity": screenInfo.scale,
      "processorFrequency": nil
    ]
  }
  
  private func getUsedMemory() -> UInt64 {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
    
    let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
      $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
        task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
      }
    }
    
    if kerr == KERN_SUCCESS {
      return info.resident_size
    } else {
      return 0
    }
  }
  
  private func getStorageInfo() -> (total: Int64?, free: Int64?) {
    guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
      return (nil, nil)
    }
    
    do {
      let values = try URL(fileURLWithPath: path).resourceValues(forKeys: [
        .volumeTotalCapacityKey,
        .volumeAvailableCapacityKey
      ])
      
      let totalCapacity = values.volumeTotalCapacity.map { Int64($0) }
      let availableCapacity = values.volumeAvailableCapacity.map { Int64($0) }
      
      return (totalCapacity, availableCapacity)
    } catch {
      return (nil, nil)
    }
  }
  
  private func getThermalState() -> Int {
    switch ProcessInfo.processInfo.thermalState {
    case .nominal:
      return 0
    case .fair:
      return 1
    case .serious:
      return 2
    case .critical:
      return 3
    @unknown default:
      return 0
    }
  }
  
  private func getBatteryInfo() -> (level: Double?, isCharging: Bool) {
    UIDevice.current.isBatteryMonitoringEnabled = true
    
    let level = UIDevice.current.batteryLevel
    let batteryLevel = level >= 0 ? Double(level) : nil
    
    let state = UIDevice.current.batteryState
    let isCharging = state == .charging || state == .full
    
    return (batteryLevel, isCharging)
  }
  
  private func getScreenInfo() -> (width: Double, height: Double, scale: Double) {
    let screen = UIScreen.main
    let bounds = screen.bounds
    let scale = screen.scale
    
    return (
      width: Double(bounds.width * scale),
      height: Double(bounds.height * scale),
      scale: Double(scale)
    )
  }
  
  private func getDeviceModel() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return identifier
  }
}
