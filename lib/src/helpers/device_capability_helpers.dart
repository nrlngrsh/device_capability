import '../device_capability.dart';
import '../models/performance_tier.dart';

/// Extension on DeviceCapability providing convenient helper methods
/// for making decisions based on device capabilities.
extension DeviceCapabilityHelpers on DeviceCapability {
  /// Returns true if animations should be reduced for better performance.
  ///
  /// Recommendations:
  /// - Disable complex animations on low-end devices
  /// - Reduce animation duration on medium-tier devices
  /// - Consider thermal state when device is throttling
  bool get shouldReduceAnimations {
    return isLowEnd || isThermalThrottling;
  }

  /// Returns true if heavy graphics effects should be disabled.
  ///
  /// Use this to disable:
  /// - Shadows
  /// - Blur effects
  /// - Complex gradients
  /// - Particle systems
  bool get shouldDisableHeavyGraphics {
    return isLowEnd || (isMidRange && isThermalThrottling);
  }

  /// Returns true if high-quality images should be avoided.
  ///
  /// Recommendations:
  /// - Use compressed/lower resolution images on low-end devices
  /// - Consider memory limitations
  /// - Take storage constraints into account
  bool get shouldUseCompressedImages {
    return isLowEnd || isMemoryLimited || isStorageLimited;
  }

  /// Returns true if video quality should be limited.
  ///
  /// Recommendations:
  /// - Limit video resolution on low-end devices
  /// - Use lower bitrates when memory or storage is limited
  bool get shouldLimitVideoQuality {
    return isLowEnd || isMemoryLimited;
  }

  /// Returns true if caching should be aggressive.
  ///
  /// On high-end devices with ample storage and memory,
  /// caching more data can improve performance.
  bool get shouldEnableAggressiveCaching {
    return isHighEnd && !isStorageLimited && !isMemoryLimited;
  }

  /// Returns true if background tasks should be limited.
  ///
  /// On low-end devices or when thermal throttling occurs,
  /// reducing background work improves user experience.
  bool get shouldLimitBackgroundTasks {
    return isLowEnd || isThermalThrottling || rawInfo.lowPowerModeEnabled == true;
  }

  /// Returns recommended number of simultaneous network requests.
  ///
  /// Higher-end devices can handle more concurrent connections.
  int get recommendedConcurrentRequests {
    switch (performanceTier) {
      case PerformanceTier.ultra:
        return 8;
      case PerformanceTier.high:
        return 6;
      case PerformanceTier.medium:
        return 4;
      case PerformanceTier.low:
        return 2;
    }
  }

  /// Returns recommended list item count for virtualization.
  ///
  /// Determines how many items should be rendered before
  /// implementing virtualization/lazy loading strategies.
  int get recommendedListThreshold {
    switch (performanceTier) {
      case PerformanceTier.ultra:
        return 200;
      case PerformanceTier.high:
        return 150;
      case PerformanceTier.medium:
        return 100;
      case PerformanceTier.low:
        return 50;
    }
  }

  /// Returns recommended frame rate target for animations.
  ///
  /// Not all devices can maintain 60 FPS smoothly.
  int get recommendedFrameRate {
    if (isLowEnd || isThermalThrottling) {
      return 30;
    } else if (isMidRange) {
      return 45;
    } else {
      return 60;
    }
  }

  /// Returns true if the app should enable performance mode.
  ///
  /// When enabled, the app should:
  /// - Disable non-essential features
  /// - Reduce visual effects
  /// - Optimize rendering
  bool get shouldEnablePerformanceMode {
    return isLowEnd || isThermalThrottling || isMemoryLimited || rawInfo.lowPowerModeEnabled == true;
  }

  /// Returns true if the app should show a performance warning to the user.
  ///
  /// Critical situations where user should be notified:
  /// - Device is critically hot
  /// - Very low memory available
  /// - Very low storage space
  bool get shouldShowPerformanceWarning {
    return thermalTier == ThermalTier.critical ||
        (memoryTier == MemoryTier.low &&
            rawInfo.usedRamBytes != null &&
            rawInfo.totalRamBytes != null &&
            rawInfo.usedRamBytes! / rawInfo.totalRamBytes! > 0.9) ||
        isStorageLimited;
  }

  /// Returns a user-friendly description of the device's capabilities.
  String get capabilityDescription {
    switch (performanceTier) {
      case PerformanceTier.ultra:
        return 'Exceptional performance capabilities';
      case PerformanceTier.high:
        return 'Strong performance capabilities';
      case PerformanceTier.medium:
        return 'Moderate performance capabilities';
      case PerformanceTier.low:
        return 'Limited performance capabilities';
    }
  }

  /// Returns recommended image cache size in MB.
  int get recommendedImageCacheSizeMB {
    if (isMemoryLimited) {
      return 50;
    } else if (memoryTier == MemoryTier.medium) {
      return 100;
    } else {
      return 200;
    }
  }

  /// Returns true if the device supports hardware acceleration well.
  ///
  /// This is an estimation based on overall performance tier.
  bool get hasGoodHardwareAcceleration {
    return performanceTier == PerformanceTier.high || performanceTier == PerformanceTier.ultra;
  }
}
