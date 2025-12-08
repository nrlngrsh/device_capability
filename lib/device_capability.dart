/// A Flutter plugin that detects device capabilities and performance characteristics.
///
/// This library provides tools for:
/// - Collecting device hardware information (RAM, CPU, storage, etc.)
/// - Calculating performance scores and tier classifications
/// - Making informed decisions about app behavior based on device capabilities
///
/// ## Usage
///
/// Initialize once at app startup:
/// ```dart
/// await DeviceCapability.instance.init();
/// ```
///
/// Access device information anywhere:
/// ```dart
/// final score = DeviceCapability.instance.performanceScore;
/// final tier = DeviceCapability.instance.performanceTier;
///
/// if (DeviceCapability.instance.shouldReduceAnimations) {
///   // Disable heavy animations
/// }
/// ```
library;

// Core API
export 'src/device_capability.dart';
// Helpers
export 'src/helpers/device_capability_helpers.dart';
// Models
export 'src/models/device_capability_config.dart';
export 'src/models/device_info.dart';
export 'src/models/device_platform.dart';
export 'src/models/performance_tier.dart';
export 'src/models/raw_device_info.dart';
