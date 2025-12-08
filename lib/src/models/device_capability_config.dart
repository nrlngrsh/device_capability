/// Configuration for device capability detection and scoring.
class DeviceCapabilityConfig {
  /// Minimum score threshold for medium tier (0-100 scale).
  final double mediumTierThreshold;

  /// Minimum score threshold for high tier (0-100 scale).
  final double highTierThreshold;

  /// Minimum score threshold for ultra tier (0-100 scale).
  final double ultraTierThreshold;

  /// Weight for RAM in overall score calculation (0.0-1.0).
  final double ramWeight;

  /// Weight for CPU in overall score calculation (0.0-1.0).
  final double cpuWeight;

  /// Weight for storage in overall score calculation (0.0-1.0).
  final double storageWeight;

  /// Weight for thermal state in overall score calculation (0.0-1.0).
  final double thermalWeight;

  /// Weight for power mode in overall score calculation (0.0-1.0).
  final double powerModeWeight;

  /// RAM threshold in GB for medium tier memory.
  final double ramMediumThresholdGB;

  /// RAM threshold in GB for high tier memory.
  final double ramHighThresholdGB;

  /// Storage free space threshold in GB for medium tier.
  final double storageMediumThresholdGB;

  /// Storage free space threshold in GB for high tier.
  final double storageHighThresholdGB;

  const DeviceCapabilityConfig({
    this.mediumTierThreshold = 35.0,
    this.highTierThreshold = 60.0,
    this.ultraTierThreshold = 80.0,
    this.ramWeight = 0.30,
    this.cpuWeight = 0.25,
    this.storageWeight = 0.20,
    this.thermalWeight = 0.15,
    this.powerModeWeight = 0.10,
    this.ramMediumThresholdGB = 3.0,
    this.ramHighThresholdGB = 6.0,
    this.storageMediumThresholdGB = 5.0,
    this.storageHighThresholdGB = 15.0,
  });

  /// Creates a copy of this config with updated values.
  DeviceCapabilityConfig copyWith({
    double? mediumTierThreshold,
    double? highTierThreshold,
    double? ultraTierThreshold,
    double? ramWeight,
    double? cpuWeight,
    double? storageWeight,
    double? thermalWeight,
    double? powerModeWeight,
    double? ramMediumThresholdGB,
    double? ramHighThresholdGB,
    double? storageMediumThresholdGB,
    double? storageHighThresholdGB,
  }) {
    return DeviceCapabilityConfig(
      mediumTierThreshold: mediumTierThreshold ?? this.mediumTierThreshold,
      highTierThreshold: highTierThreshold ?? this.highTierThreshold,
      ultraTierThreshold: ultraTierThreshold ?? this.ultraTierThreshold,
      ramWeight: ramWeight ?? this.ramWeight,
      cpuWeight: cpuWeight ?? this.cpuWeight,
      storageWeight: storageWeight ?? this.storageWeight,
      thermalWeight: thermalWeight ?? this.thermalWeight,
      powerModeWeight: powerModeWeight ?? this.powerModeWeight,
      ramMediumThresholdGB: ramMediumThresholdGB ?? this.ramMediumThresholdGB,
      ramHighThresholdGB: ramHighThresholdGB ?? this.ramHighThresholdGB,
      storageMediumThresholdGB:
          storageMediumThresholdGB ?? this.storageMediumThresholdGB,
      storageHighThresholdGB:
          storageHighThresholdGB ?? this.storageHighThresholdGB,
    );
  }
}
