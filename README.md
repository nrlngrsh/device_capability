# Device Capability

[![pub package](https://img.shields.io/pub/v/device_capability.svg)](https://pub.dev/packages/device_capability)

A Flutter plugin that detects device hardware capabilities, calculates performance scores and tier classifications. Initialize once at app startup and access device information instantly throughout your app session without additional overhead.

## Features

- **One-time initialization** - Collect device data once, use everywhere
- **Performance scoring** - Get an overall device performance score (0-100)
- **Tier classification** - Automatic categorization into low/medium/high/ultra tiers
- **Memory & storage analysis** - Detailed RAM and storage tier detection
- **Thermal monitoring** - Track device temperature state
- **Zero external dependencies** - Lightweight and self-contained
- **Smart recommendations** - Built-in helpers for optimizing UX based on device
- **Cross-platform** - Works on both iOS and Android
- **Well-tested** - Full unit test coverage

## What Makes This Different?

This package doesn't just give you raw device specs. Instead, it analyzes the data and provides practical recommendations for your app. For example, rather than telling you the device has 2GB RAM, it tells you whether you should reduce animations or use compressed images.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  device_capability: ^0.1.0
```

Run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize at App Startup

```dart
import 'package:device_capability/device_capability.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize device capability detection
  await DeviceCapability.instance.init();

  runApp(MyApp());
}
```

### 2. Access Anywhere in Your App

```dart
// Get performance information
final score = DeviceCapability.instance.performanceScore;
final tier = DeviceCapability.instance.performanceTier;

print('Device score: $score/100');
print('Device tier: ${tier.name}'); // low, medium, high, ultra
```

### 3. Use Smart Helpers

```dart
// Make UX decisions based on device capabilities
if (DeviceCapability.instance.shouldReduceAnimations) {
  // Disable complex animations
}

if (DeviceCapability.instance.shouldUseCompressedImages) {
  // Load lower quality images
}

if (DeviceCapability.instance.isLowEnd) {
  // Simplify UI for better performance
}
```

## Usage Examples

### Conditional Animation Quality

```dart
Widget build(BuildContext context) {
  final dc = DeviceCapability.instance;

  return AnimatedContainer(
    duration: dc.shouldReduceAnimations
        ? Duration(milliseconds: 100)
        : Duration(milliseconds: 300),
    curve: dc.shouldReduceAnimations ? Curves.linear : Curves.easeInOut,
    // ... other properties
  );
}
```

### Adaptive Image Loading

```dart
String getImageUrl(String baseUrl) {
  final dc = DeviceCapability.instance;

  if (dc.shouldUseCompressedImages) {
    return '$baseUrl?quality=medium';
  } else if (dc.isHighEnd) {
    return '$baseUrl?quality=high';
  }
  return baseUrl;
}
```

### Performance-Based List Configuration

```dart
ListView.builder(
  itemCount: items.length,
  cacheExtent: DeviceCapability.instance.isHighEnd ? 500 : 200,
  itemBuilder: (context, index) {
    // Build list items
  },
);
```

### Network Request Optimization

```dart
final maxConcurrentRequests =
    DeviceCapability.instance.recommendedConcurrentRequests;

// Use this to limit parallel network calls
```

## API Reference

### Main Properties

| Property | Type | Description |
|----------|------|-------------|
| `performanceScore` | `double` | Overall performance score (0-100) |
| `performanceTier` | `PerformanceTier` | low, medium, high, or ultra |
| `memoryTier` | `MemoryTier` | RAM capacity tier |
| `storageTier` | `StorageTier` | Storage availability tier |
| `thermalTier` | `ThermalTier` | Device temperature state |
| `platform` | `DevicePlatform` | Android or iOS |
| `rawInfo` | `RawDeviceInfo` | Raw hardware data |

### Helper Properties

| Helper | Returns | Description |
|--------|---------|-------------|
| `isLowEnd` | `bool` | True for low-end devices |
| `isMidRange` | `bool` | True for medium-tier devices |
| `isHighEnd` | `bool` | True for high/ultra devices |
| `shouldReduceAnimations` | `bool` | Recommend reducing animations |
| `shouldDisableHeavyGraphics` | `bool` | Recommend disabling effects |
| `shouldUseCompressedImages` | `bool` | Recommend compressed images |
| `shouldLimitVideoQuality` | `bool` | Recommend lower video quality |
| `shouldEnableAggressiveCaching` | `bool` | Good for aggressive caching |
| `shouldLimitBackgroundTasks` | `bool` | Limit background processing |
| `recommendedFrameRate` | `int` | Target FPS (30, 45, or 60) |
| `recommendedConcurrentRequests` | `int` | Max parallel requests (2-8) |
| `recommendedListThreshold` | `int` | Virtualization threshold |
| `recommendedImageCacheSizeMB` | `int` | Image cache size in MB |

## Configuration

Customize scoring thresholds and weights:

```dart
await DeviceCapability.instance.init(
  DeviceCapabilityConfig(
    mediumTierThreshold: 40.0,  // Default: 35.0
    highTierThreshold: 70.0,     // Default: 60.0
    ultraTierThreshold: 85.0,    // Default: 80.0
    ramWeight: 0.35,             // Default: 0.30
    cpuWeight: 0.25,             // Default: 0.25
    storageWeight: 0.20,         // Default: 0.20
    thermalWeight: 0.15,         // Default: 0.15
    powerModeWeight: 0.05,       // Default: 0.10
  ),
);
```

## How Performance Score is Calculated

The performance score (0-100) is calculated using weighted metrics:

- **RAM (30%)**: Total capacity + usage ratio
- **CPU (25%)**: Core count + processor frequency
- **Storage (20%)**: Free space + usage ratio
- **Thermal (15%)**: Current temperature state
- **Power Mode (10%)**: Battery saver enabled/disabled

### Tier Thresholds (Default)

- **Low**: 0-34
- **Medium**: 35-59
- **High**: 60-79
- **Ultra**: 80-100

## Raw Device Information

Access unprocessed hardware data:

```dart
final raw = DeviceCapability.instance.rawInfo;

print('CPU Cores: ${raw.cpuCores}');
print('Total RAM: ${raw.totalRamBytes} bytes');
print('Used RAM: ${raw.usedRamBytes} bytes');
print('Total Storage: ${raw.totalStorageBytes} bytes');
print('Free Storage: ${raw.freeStorageBytes} bytes');
print('Device Model: ${raw.deviceModel}');
print('Thermal State: ${raw.thermalState}');
print('Low Power Mode: ${raw.lowPowerModeEnabled}');
print('Battery Level: ${raw.batteryLevel}');
print('Screen Resolution: ${raw.screenWidth} x ${raw.screenHeight}');
```

## Platform-Specific Details

### Android
- Collects: CPU cores, RAM, storage, SDK level, thermal status, battery info
- Minimum SDK: 21 (Android 5.0)

### iOS
- Collects: CPU cores, RAM, storage, device model, thermal state, low power mode
- Minimum iOS: 12.0

## Example App

Run the example app to see all features in action:

```bash
cd example
flutter run
```

The example demonstrates:
- All available metrics and tiers
- Real-time device information display
- Helper method recommendations
- Raw data visualization

## Testing

The package includes unit tests covering:
- Performance scoring algorithms
- Tier classification logic
- Configuration customization
- Raw data parsing

## Roadmap

Planned features for future releases:

- Web platform support
- GPU performance metrics
- Battery health tracking
- Network speed detection
- Performance monitoring over time

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

## Issues

Found a bug or have a feature request? Please [open an issue](https://github.com/nrlngrsh/device_capability/issues).

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Authors

- **Nurlan** - [nrlngrsh](https://github.com/nrlngrsh)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

Made with ❤️ for the Flutter community

