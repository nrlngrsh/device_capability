import 'device_platform.dart';
import 'performance_tier.dart';
import 'raw_device_info.dart';

/// Device capability information with calculated scores and tiers.
class DeviceInfo {
  /// The platform of the device.
  final DevicePlatform platform;

  /// Overall performance score (0-100).
  final double performanceScore;

  /// Overall performance tier.
  final PerformanceTier performanceTier;

  /// Memory tier based on available RAM.
  final MemoryTier memoryTier;

  /// Storage tier based on available space.
  final StorageTier storageTier;

  /// Thermal state tier.
  final ThermalTier thermalTier;

  /// Raw device information collected from native platform.
  final RawDeviceInfo rawInfo;

  const DeviceInfo({
    required this.platform,
    required this.performanceScore,
    required this.performanceTier,
    required this.memoryTier,
    required this.storageTier,
    required this.thermalTier,
    required this.rawInfo,
  });

  @override
  String toString() {
    return 'DeviceInfo('
        'platform: ${platform.name}, '
        'score: ${performanceScore.toStringAsFixed(1)}, '
        'tier: ${performanceTier.name}, '
        'memory: ${memoryTier.name}, '
        'storage: ${storageTier.name}, '
        'thermal: ${thermalTier.name}'
        ')';
  }
}
