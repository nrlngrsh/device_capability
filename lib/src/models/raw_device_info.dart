import 'device_platform.dart';

/// Contains raw device information collected from the native platform.
class RawDeviceInfo {
  /// The platform of the device.
  final DevicePlatform platform;

  /// Number of CPU cores (Android/iOS).
  final int? cpuCores;

  /// Total physical RAM in bytes.
  final int? totalRamBytes;

  /// Used RAM in bytes.
  final int? usedRamBytes;

  /// Total internal storage in bytes.
  final int? totalStorageBytes;

  /// Free internal storage in bytes.
  final int? freeStorageBytes;

  /// Android SDK level (Android only).
  final int? sdkLevel;

  /// Device model identifier (iOS: e.g., "iPhone14,2").
  final String? deviceModel;

  /// Thermal state value (0=normal, 1=fair, 2=serious, 3=critical).
  final int? thermalState;

  /// Whether low power mode is enabled.
  final bool? lowPowerModeEnabled;

  /// Battery level (0.0 to 1.0).
  final double? batteryLevel;

  /// Whether device is currently charging.
  final bool? isCharging;

  /// Screen width in pixels.
  final double? screenWidth;

  /// Screen height in pixels.
  final double? screenHeight;

  /// Screen pixel density.
  final double? screenDensity;

  /// Available processor frequency in MHz (if available).
  final int? processorFrequency;

  const RawDeviceInfo({
    required this.platform,
    this.cpuCores,
    this.totalRamBytes,
    this.usedRamBytes,
    this.totalStorageBytes,
    this.freeStorageBytes,
    this.sdkLevel,
    this.deviceModel,
    this.thermalState,
    this.lowPowerModeEnabled,
    this.batteryLevel,
    this.isCharging,
    this.screenWidth,
    this.screenHeight,
    this.screenDensity,
    this.processorFrequency,
  });

  /// Creates a [RawDeviceInfo] from a map received from the platform channel.
  factory RawDeviceInfo.fromMap(Map<dynamic, dynamic> map) {
    final platformStr = map['platform'] as String?;
    DevicePlatform platform = DevicePlatform.unknown;
    if (platformStr == 'android') {
      platform = DevicePlatform.android;
    } else if (platformStr == 'ios') {
      platform = DevicePlatform.ios;
    }

    return RawDeviceInfo(
      platform: platform,
      cpuCores: map['cpuCores'] as int?,
      totalRamBytes: map['totalRamBytes'] as int?,
      usedRamBytes: map['usedRamBytes'] as int?,
      totalStorageBytes: map['totalStorageBytes'] as int?,
      freeStorageBytes: map['freeStorageBytes'] as int?,
      sdkLevel: map['sdkLevel'] as int?,
      deviceModel: map['deviceModel'] as String?,
      thermalState: map['thermalState'] as int?,
      lowPowerModeEnabled: map['lowPowerModeEnabled'] as bool?,
      batteryLevel: (map['batteryLevel'] as num?)?.toDouble(),
      isCharging: map['isCharging'] as bool?,
      screenWidth: (map['screenWidth'] as num?)?.toDouble(),
      screenHeight: (map['screenHeight'] as num?)?.toDouble(),
      screenDensity: (map['screenDensity'] as num?)?.toDouble(),
      processorFrequency: map['processorFrequency'] as int?,
    );
  }

  /// Converts this object to a map for debugging or serialization.
  Map<String, dynamic> toMap() {
    return {
      'platform': platform.name,
      'cpuCores': cpuCores,
      'totalRamBytes': totalRamBytes,
      'usedRamBytes': usedRamBytes,
      'totalStorageBytes': totalStorageBytes,
      'freeStorageBytes': freeStorageBytes,
      'sdkLevel': sdkLevel,
      'deviceModel': deviceModel,
      'thermalState': thermalState,
      'lowPowerModeEnabled': lowPowerModeEnabled,
      'batteryLevel': batteryLevel,
      'isCharging': isCharging,
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'screenDensity': screenDensity,
      'processorFrequency': processorFrequency,
    };
  }

  @override
  String toString() => 'RawDeviceInfo(${toMap()})';
}
