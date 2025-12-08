import 'package:flutter/services.dart';

import '../models/raw_device_info.dart';

/// Platform channel interface for communicating with native code.
class DeviceCapabilityPlatform {
  static const MethodChannel _channel = MethodChannel('device_capability');

  /// Collects raw device information from the native platform.
  ///
  /// This method calls the native platform (Android/iOS) to gather
  /// hardware and system information about the device.
  ///
  /// Returns a [RawDeviceInfo] object containing all collected data.
  ///
  /// Throws a [PlatformException] if the native call fails.
  Future<RawDeviceInfo> getDeviceInfo() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'getDeviceInfo',
      );
      return RawDeviceInfo.fromMap(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to get device info: ${e.message}');
    }
  }
}
