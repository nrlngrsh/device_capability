import '../models/device_capability_config.dart';
import '../models/device_info.dart';
import '../models/performance_tier.dart';
import '../models/raw_device_info.dart';

/// Engine for calculating device performance scores and tiers.
class PerformanceEngine {
  final DeviceCapabilityConfig config;

  const PerformanceEngine(this.config);

  /// Processes raw device information and calculates performance metrics.
  ///
  /// Takes [rawInfo] collected from the native platform and applies
  /// scoring algorithms to determine overall performance score and
  /// various tier classifications.
  DeviceInfo processDeviceInfo(RawDeviceInfo rawInfo) {
    final performanceScore = _calculatePerformanceScore(rawInfo);
    final performanceTier = _determinePerformanceTier(performanceScore);
    final memoryTier = _determineMemoryTier(rawInfo);
    final storageTier = _determineStorageTier(rawInfo);
    final thermalTier = _determineThermalTier(rawInfo);

    return DeviceInfo(
      platform: rawInfo.platform,
      performanceScore: performanceScore,
      performanceTier: performanceTier,
      memoryTier: memoryTier,
      storageTier: storageTier,
      thermalTier: thermalTier,
      rawInfo: rawInfo,
    );
  }

  /// Calculates overall performance score (0-100).
  double _calculatePerformanceScore(RawDeviceInfo rawInfo) {
    double score = 0.0;

    // RAM score contribution (weighted)
    final ramScore = _calculateRamScore(rawInfo);
    score += ramScore * config.ramWeight * 100;

    // CPU score contribution (weighted)
    final cpuScore = _calculateCpuScore(rawInfo);
    score += cpuScore * config.cpuWeight * 100;

    // Storage score contribution (weighted)
    final storageScore = _calculateStorageScore(rawInfo);
    score += storageScore * config.storageWeight * 100;

    // Thermal penalty (weighted)
    final thermalScore = _calculateThermalScore(rawInfo);
    score += thermalScore * config.thermalWeight * 100;

    // Power mode penalty (weighted)
    final powerScore = _calculatePowerScore(rawInfo);
    score += powerScore * config.powerModeWeight * 100;

    return score.clamp(0.0, 100.0);
  }

  /// Calculates RAM score (0.0-1.0) based on total and used memory.
  double _calculateRamScore(RawDeviceInfo info) {
    if (info.totalRamBytes == null) return 0.5;

    final totalGB = info.totalRamBytes! / (1024 * 1024 * 1024);
    final usedRatio = info.usedRamBytes != null && info.totalRamBytes! > 0
        ? info.usedRamBytes! / info.totalRamBytes!
        : 0.5;

    // Score based on total RAM (0-0.7)
    double ramCapacityScore = 0.0;
    if (totalGB >= 8) {
      ramCapacityScore = 0.7;
    } else if (totalGB >= 6) {
      ramCapacityScore = 0.6;
    } else if (totalGB >= 4) {
      ramCapacityScore = 0.5;
    } else if (totalGB >= 3) {
      ramCapacityScore = 0.4;
    } else if (totalGB >= 2) {
      ramCapacityScore = 0.3;
    } else {
      ramCapacityScore = 0.2;
    }

    // Bonus for low memory usage (0-0.3)
    final memoryPressureScore = (1.0 - usedRatio) * 0.3;

    return (ramCapacityScore + memoryPressureScore).clamp(0.0, 1.0);
  }

  /// Calculates CPU score (0.0-1.0) based on core count and frequency.
  double _calculateCpuScore(RawDeviceInfo info) {
    double score = 0.5; // Default baseline

    // Core count contribution (0-0.8)
    if (info.cpuCores != null) {
      if (info.cpuCores! >= 8) {
        score = 0.8;
      } else if (info.cpuCores! >= 6) {
        score = 0.7;
      } else if (info.cpuCores! >= 4) {
        score = 0.6;
      } else if (info.cpuCores! >= 2) {
        score = 0.5;
      } else {
        score = 0.3;
      }
    }

    // Frequency bonus (0-0.2)
    if (info.processorFrequency != null) {
      final freqGHz = info.processorFrequency! / 1000.0;
      if (freqGHz >= 3.0) {
        score += 0.2;
      } else if (freqGHz >= 2.5) {
        score += 0.15;
      } else if (freqGHz >= 2.0) {
        score += 0.1;
      } else if (freqGHz >= 1.5) {
        score += 0.05;
      }
    }

    return score.clamp(0.0, 1.0);
  }

  /// Calculates storage score (0.0-1.0) based on available space.
  double _calculateStorageScore(RawDeviceInfo info) {
    if (info.freeStorageBytes == null || info.totalStorageBytes == null) {
      return 0.5;
    }

    final freeGB = info.freeStorageBytes! / (1024 * 1024 * 1024);
    final usageRatio = info.totalStorageBytes! > 0
        ? (info.totalStorageBytes! - info.freeStorageBytes!) /
              info.totalStorageBytes!
        : 0.5;

    // Score based on free space (0-0.7)
    double freeSpaceScore = 0.0;
    if (freeGB >= 30) {
      freeSpaceScore = 0.7;
    } else if (freeGB >= 15) {
      freeSpaceScore = 0.6;
    } else if (freeGB >= 10) {
      freeSpaceScore = 0.5;
    } else if (freeGB >= 5) {
      freeSpaceScore = 0.4;
    } else if (freeGB >= 2) {
      freeSpaceScore = 0.3;
    } else {
      freeSpaceScore = 0.2;
    }

    // Bonus for low storage usage (0-0.3)
    final usageScore = (1.0 - usageRatio) * 0.3;

    return (freeSpaceScore + usageScore).clamp(0.0, 1.0);
  }

  /// Calculates thermal score (0.0-1.0) - lower temperature = higher score.
  double _calculateThermalScore(RawDeviceInfo info) {
    if (info.thermalState == null) return 1.0;

    switch (info.thermalState!) {
      case 0: // Normal
        return 1.0;
      case 1: // Fair/Moderate
        return 0.75;
      case 2: // Serious/High
        return 0.5;
      case 3: // Critical
        return 0.25;
      default:
        return 1.0;
    }
  }

  /// Calculates power mode score (0.0-1.0) - penalty if low power mode is on.
  double _calculatePowerScore(RawDeviceInfo info) {
    if (info.lowPowerModeEnabled == null) return 1.0;
    return info.lowPowerModeEnabled! ? 0.5 : 1.0;
  }

  /// Determines performance tier based on overall score.
  PerformanceTier _determinePerformanceTier(double score) {
    if (score >= config.ultraTierThreshold) {
      return PerformanceTier.ultra;
    } else if (score >= config.highTierThreshold) {
      return PerformanceTier.high;
    } else if (score >= config.mediumTierThreshold) {
      return PerformanceTier.medium;
    } else {
      return PerformanceTier.low;
    }
  }

  /// Determines memory tier based on RAM capacity.
  MemoryTier _determineMemoryTier(RawDeviceInfo info) {
    if (info.totalRamBytes == null) return MemoryTier.medium;

    final totalGB = info.totalRamBytes! / (1024 * 1024 * 1024);

    if (totalGB >= config.ramHighThresholdGB) {
      return MemoryTier.high;
    } else if (totalGB >= config.ramMediumThresholdGB) {
      return MemoryTier.medium;
    } else {
      return MemoryTier.low;
    }
  }

  /// Determines storage tier based on free space.
  StorageTier _determineStorageTier(RawDeviceInfo info) {
    if (info.freeStorageBytes == null) return StorageTier.medium;

    final freeGB = info.freeStorageBytes! / (1024 * 1024 * 1024);

    if (freeGB >= config.storageHighThresholdGB) {
      return StorageTier.high;
    } else if (freeGB >= config.storageMediumThresholdGB) {
      return StorageTier.medium;
    } else {
      return StorageTier.low;
    }
  }

  /// Determines thermal tier based on thermal state.
  ThermalTier _determineThermalTier(RawDeviceInfo info) {
    if (info.thermalState == null) return ThermalTier.normal;

    switch (info.thermalState!) {
      case 0:
        return ThermalTier.normal;
      case 1:
        return ThermalTier.moderate;
      case 2:
        return ThermalTier.high;
      case 3:
        return ThermalTier.critical;
      default:
        return ThermalTier.normal;
    }
  }
}
