import 'package:device_capability/device_capability.dart';
import 'package:device_capability/src/engine/performance_engine.dart';
import 'package:test/test.dart';

void main() {
  group('PerformanceEngine Tests', () {
    late PerformanceEngine engine;

    setUp(() {
      engine = const PerformanceEngine(DeviceCapabilityConfig());
    });

    test('Low-end device detection', () {
      final rawInfo = RawDeviceInfo(
        platform: DevicePlatform.android,
        cpuCores: 2,
        totalRamBytes: (1.5 * 1024 * 1024 * 1024).toInt(), // 1.5 GB
        usedRamBytes: (1.2 * 1024 * 1024 * 1024)
            .toInt(), // 1.2 GB used (high pressure)
        totalStorageBytes: 16 * 1024 * 1024 * 1024,
        freeStorageBytes: (1.5 * 1024 * 1024 * 1024).toInt(), // Only 1.5GB free
        thermalState: 1, // Moderate thermal
        lowPowerModeEnabled: false,
      );

      final deviceInfo = engine.processDeviceInfo(rawInfo);

      // With 1.5GB RAM, 2 cores, low storage, this should be low-medium range
      expect(deviceInfo.memoryTier, MemoryTier.low);
      expect(deviceInfo.performanceScore, lessThan(50.0));
    });

    test('High-end device detection', () {
      final rawInfo = RawDeviceInfo(
        platform: DevicePlatform.ios,
        cpuCores: 8,
        totalRamBytes: 8 * 1024 * 1024 * 1024, // 8 GB
        usedRamBytes: 2 * 1024 * 1024 * 1024,
        totalStorageBytes: 256 * 1024 * 1024 * 1024,
        freeStorageBytes: 100 * 1024 * 1024 * 1024,
        thermalState: 0,
        lowPowerModeEnabled: false,
        processorFrequency: 3000,
      );

      final deviceInfo = engine.processDeviceInfo(rawInfo);

      expect(
        deviceInfo.performanceTier,
        anyOf(PerformanceTier.high, PerformanceTier.ultra),
      );
      expect(deviceInfo.memoryTier, MemoryTier.high);
      expect(deviceInfo.storageTier, StorageTier.high);
      expect(deviceInfo.performanceScore, greaterThan(60.0));
    });

    test('Mid-range device detection', () {
      final rawInfo = RawDeviceInfo(
        platform: DevicePlatform.android,
        cpuCores: 4,
        totalRamBytes: 4 * 1024 * 1024 * 1024, // 4 GB
        usedRamBytes: (1.5 * 1024 * 1024 * 1024).toInt(),
        totalStorageBytes: 64 * 1024 * 1024 * 1024,
        freeStorageBytes: 6 * 1024 * 1024 * 1024, // 6GB free
        thermalState: 0,
        lowPowerModeEnabled: false,
      );

      final deviceInfo = engine.processDeviceInfo(rawInfo);

      // 4GB RAM, 4 cores should give reasonable score
      expect(deviceInfo.memoryTier, MemoryTier.medium);
      expect(deviceInfo.performanceScore, greaterThan(35.0));
    });

    test('Thermal throttling detection', () {
      final rawInfo = RawDeviceInfo(
        platform: DevicePlatform.android,
        cpuCores: 8,
        totalRamBytes: 6 * 1024 * 1024 * 1024,
        usedRamBytes: 2 * 1024 * 1024 * 1024,
        totalStorageBytes: 128 * 1024 * 1024 * 1024,
        freeStorageBytes: 50 * 1024 * 1024 * 1024,
        thermalState: 3, // Critical
        lowPowerModeEnabled: false,
      );

      final deviceInfo = engine.processDeviceInfo(rawInfo);

      expect(deviceInfo.thermalTier, ThermalTier.critical);
      // Score should be reduced due to thermal state
    });

    test('Low power mode penalty', () {
      final rawInfo1 = RawDeviceInfo(
        platform: DevicePlatform.ios,
        cpuCores: 6,
        totalRamBytes: 4 * 1024 * 1024 * 1024,
        usedRamBytes: 2 * 1024 * 1024 * 1024,
        totalStorageBytes: 64 * 1024 * 1024 * 1024,
        freeStorageBytes: 20 * 1024 * 1024 * 1024,
        thermalState: 0,
        lowPowerModeEnabled: false,
      );

      final rawInfo2 = rawInfo1.copyWith(lowPowerModeEnabled: true);

      final deviceInfo1 = engine.processDeviceInfo(rawInfo1);
      final deviceInfo2 = engine.processDeviceInfo(rawInfo2);

      expect(
        deviceInfo2.performanceScore,
        lessThan(deviceInfo1.performanceScore),
      );
    });

    test('Custom config changes thresholds', () {
      final customConfig = DeviceCapabilityConfig(
        mediumTierThreshold: 50.0,
        highTierThreshold: 75.0,
      );
      final customEngine = PerformanceEngine(customConfig);

      final rawInfo = RawDeviceInfo(
        platform: DevicePlatform.android,
        cpuCores: 4,
        totalRamBytes: 4 * 1024 * 1024 * 1024,
        usedRamBytes: 2 * 1024 * 1024 * 1024,
        totalStorageBytes: 64 * 1024 * 1024 * 1024,
        freeStorageBytes: 10 * 1024 * 1024 * 1024,
        thermalState: 0,
        lowPowerModeEnabled: false,
      );

      final deviceInfo = customEngine.processDeviceInfo(rawInfo);

      // With higher thresholds, same device might be classified lower
      expect(
        deviceInfo.performanceTier,
        anyOf(PerformanceTier.low, PerformanceTier.medium),
      );
    });
  });

  group('DeviceCapabilityConfig Tests', () {
    test('Default config has valid values', () {
      const config = DeviceCapabilityConfig();

      expect(config.mediumTierThreshold, 35.0);
      expect(config.highTierThreshold, 60.0);
      expect(config.ultraTierThreshold, 80.0);
      expect(
        config.ramWeight +
            config.cpuWeight +
            config.storageWeight +
            config.thermalWeight +
            config.powerModeWeight,
        1.0,
      );
    });

    test('Config copyWith works correctly', () {
      const config = DeviceCapabilityConfig();
      final newConfig = config.copyWith(mediumTierThreshold: 40.0);

      expect(newConfig.mediumTierThreshold, 40.0);
      expect(newConfig.highTierThreshold, config.highTierThreshold);
    });
  });

  group('RawDeviceInfo Tests', () {
    test('fromMap parses correctly', () {
      final map = {
        'platform': 'android',
        'cpuCores': 8,
        'totalRamBytes': 8589934592,
        'usedRamBytes': 4294967296,
        'thermalState': 0,
        'lowPowerModeEnabled': false,
      };

      final rawInfo = RawDeviceInfo.fromMap(map);

      expect(rawInfo.platform, DevicePlatform.android);
      expect(rawInfo.cpuCores, 8);
      expect(rawInfo.totalRamBytes, 8589934592);
      expect(rawInfo.usedRamBytes, 4294967296);
      expect(rawInfo.thermalState, 0);
      expect(rawInfo.lowPowerModeEnabled, false);
    });

    test('toMap serializes correctly', () {
      const rawInfo = RawDeviceInfo(
        platform: DevicePlatform.ios,
        cpuCores: 6,
        totalRamBytes: 6442450944,
      );

      final map = rawInfo.toMap();

      expect(map['platform'], 'ios');
      expect(map['cpuCores'], 6);
      expect(map['totalRamBytes'], 6442450944);
    });
  });
}

extension on RawDeviceInfo {
  RawDeviceInfo copyWith({
    DevicePlatform? platform,
    int? cpuCores,
    int? totalRamBytes,
    int? usedRamBytes,
    int? totalStorageBytes,
    int? freeStorageBytes,
    int? sdkLevel,
    String? deviceModel,
    int? thermalState,
    bool? lowPowerModeEnabled,
    double? batteryLevel,
    bool? isCharging,
    double? screenWidth,
    double? screenHeight,
    double? screenDensity,
    int? processorFrequency,
  }) {
    return RawDeviceInfo(
      platform: platform ?? this.platform,
      cpuCores: cpuCores ?? this.cpuCores,
      totalRamBytes: totalRamBytes ?? this.totalRamBytes,
      usedRamBytes: usedRamBytes ?? this.usedRamBytes,
      totalStorageBytes: totalStorageBytes ?? this.totalStorageBytes,
      freeStorageBytes: freeStorageBytes ?? this.freeStorageBytes,
      sdkLevel: sdkLevel ?? this.sdkLevel,
      deviceModel: deviceModel ?? this.deviceModel,
      thermalState: thermalState ?? this.thermalState,
      lowPowerModeEnabled: lowPowerModeEnabled ?? this.lowPowerModeEnabled,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isCharging: isCharging ?? this.isCharging,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      screenDensity: screenDensity ?? this.screenDensity,
      processorFrequency: processorFrequency ?? this.processorFrequency,
    );
  }
}
