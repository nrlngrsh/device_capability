import 'engine/performance_engine.dart';
import 'models/device_capability_config.dart';
import 'models/device_info.dart';
import 'models/device_platform.dart';
import 'models/performance_tier.dart';
import 'models/raw_device_info.dart';
import 'platform/device_capability_platform.dart';

/// Main singleton class for device capability detection.
///
/// This class provides the primary interface for initializing and accessing
/// device capability information throughout your Flutter application.
///
/// Usage:
/// ```dart
/// // Initialize once at app startup
/// await DeviceCapability.instance.init();
///
/// // Access anywhere in your app
/// final score = DeviceCapability.instance.performanceScore;
/// final tier = DeviceCapability.instance.performanceTier;
/// ```
class DeviceCapability {
  static final DeviceCapability _instance = DeviceCapability._internal();

  /// Singleton instance of DeviceCapability.
  static DeviceCapability get instance => _instance;

  DeviceCapability._internal();

  DeviceInfo? _deviceInfo;
  bool _isInitialized = false;

  /// Returns whether the device capability detector has been initialized.
  bool get isInitialized => _isInitialized;

  /// Initializes the device capability detector.
  ///
  /// This method should be called once at application startup, preferably
  /// in your main() function or in the first screen's initState.
  ///
  /// The [config] parameter allows customization of scoring thresholds
  /// and weights. If not provided, default configuration is used.
  ///
  /// Example:
  /// ```dart
  /// await DeviceCapability.instance.init(
  ///   DeviceCapabilityConfig(
  ///     mediumTierThreshold: 40.0,
  ///     highTierThreshold: 70.0,
  ///   ),
  /// );
  /// ```
  ///
  /// Throws an [Exception] if initialization fails.
  Future<void> init([DeviceCapabilityConfig? config]) async {
    if (_isInitialized) {
      // Already initialized, skip
      return;
    }

    try {
      // Step 1: Collect raw device information from native platform
      final platform = DeviceCapabilityPlatform();
      final rawInfo = await platform.getDeviceInfo();

      // Step 2: Process raw data and calculate scores/tiers
      final engine = PerformanceEngine(config ?? const DeviceCapabilityConfig());
      _deviceInfo = engine.processDeviceInfo(rawInfo);

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize DeviceCapability: $e');
    }
  }

  /// Ensures the instance is initialized before accessing data.
  void _ensureInitialized() {
    if (!_isInitialized || _deviceInfo == null) {
      throw StateError(
        'DeviceCapability has not been initialized. '
        'Call DeviceCapability.instance.init() first.',
      );
    }
  }

  /// Returns the complete device information object.
  ///
  /// Throws [StateError] if not initialized.
  DeviceInfo get deviceInfo {
    _ensureInitialized();
    return _deviceInfo!;
  }

  /// Returns the device platform (Android, iOS, or Unknown).
  ///
  /// Throws [StateError] if not initialized.
  DevicePlatform get platform {
    _ensureInitialized();
    return _deviceInfo!.platform;
  }

  /// Returns the overall performance score (0-100).
  ///
  /// Higher scores indicate better device performance.
  ///
  /// Throws [StateError] if not initialized.
  double get performanceScore {
    _ensureInitialized();
    return _deviceInfo!.performanceScore;
  }

  /// Returns the overall performance tier.
  ///
  /// Possible values: low, medium, high, ultra
  ///
  /// Throws [StateError] if not initialized.
  PerformanceTier get performanceTier {
    _ensureInitialized();
    return _deviceInfo!.performanceTier;
  }

  /// Returns the memory tier based on RAM capacity.
  ///
  /// Possible values: low, medium, high
  ///
  /// Throws [StateError] if not initialized.
  MemoryTier get memoryTier {
    _ensureInitialized();
    return _deviceInfo!.memoryTier;
  }

  /// Returns the storage tier based on available space.
  ///
  /// Possible values: low, medium, high
  ///
  /// Throws [StateError] if not initialized.
  StorageTier get storageTier {
    _ensureInitialized();
    return _deviceInfo!.storageTier;
  }

  /// Returns the thermal state tier.
  ///
  /// Possible values: normal, moderate, high, critical
  ///
  /// Throws [StateError] if not initialized.
  ThermalTier get thermalTier {
    _ensureInitialized();
    return _deviceInfo!.thermalTier;
  }

  /// Returns the raw device information collected from the platform.
  ///
  /// This includes unprocessed data like exact RAM bytes, CPU cores,
  /// storage info, thermal state values, etc.
  ///
  /// Throws [StateError] if not initialized.
  RawDeviceInfo get rawInfo {
    _ensureInitialized();
    return _deviceInfo!.rawInfo;
  }

  /// Returns true if this is a low-end device.
  bool get isLowEnd {
    _ensureInitialized();
    return _deviceInfo!.performanceTier == PerformanceTier.low;
  }

  /// Returns true if this is a medium-tier device.
  bool get isMidRange {
    _ensureInitialized();
    return _deviceInfo!.performanceTier == PerformanceTier.medium;
  }

  /// Returns true if this is a high-end device.
  bool get isHighEnd {
    _ensureInitialized();
    return _deviceInfo!.performanceTier == PerformanceTier.high ||
        _deviceInfo!.performanceTier == PerformanceTier.ultra;
  }

  /// Returns true if thermal state is elevated (high or critical).
  bool get isThermalThrottling {
    _ensureInitialized();
    return _deviceInfo!.thermalTier == ThermalTier.high || _deviceInfo!.thermalTier == ThermalTier.critical;
  }

  /// Returns true if storage space is limited.
  bool get isStorageLimited {
    _ensureInitialized();
    return _deviceInfo!.storageTier == StorageTier.low;
  }

  /// Returns true if memory is limited.
  bool get isMemoryLimited {
    _ensureInitialized();
    return _deviceInfo!.memoryTier == MemoryTier.low;
  }

  /// Resets the singleton state (useful for testing).
  void reset() {
    _deviceInfo = null;
    _isInitialized = false;
  }
}
