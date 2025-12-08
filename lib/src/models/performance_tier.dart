/// Represents the performance tier category of a device.
enum PerformanceTier {
  /// Low-end devices with limited capabilities.
  low,

  /// Mid-range devices with moderate capabilities.
  medium,

  /// High-end devices with strong capabilities.
  high,

  /// Ultra high-end devices with exceptional capabilities.
  ultra,
}

/// Represents the memory tier category of a device.
enum MemoryTier {
  /// Limited memory capacity.
  low,

  /// Moderate memory capacity.
  medium,

  /// High memory capacity.
  high,
}

/// Represents the storage tier category of a device.
enum StorageTier {
  /// Limited storage space.
  low,

  /// Moderate storage space.
  medium,

  /// Ample storage space.
  high,
}

/// Represents the thermal state tier of a device.
enum ThermalTier {
  /// Normal temperature, no throttling.
  normal,

  /// Slightly elevated temperature.
  moderate,

  /// High temperature, possible throttling.
  high,

  /// Critical temperature, severe throttling.
  critical,
}
