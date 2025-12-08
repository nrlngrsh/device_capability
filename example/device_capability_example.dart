import 'package:device_capability/device_capability.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize device capability detection
  await DeviceCapability.instance.init();

  runApp(const DeviceCapabilityExampleApp());
}

class DeviceCapabilityExampleApp extends StatelessWidget {
  const DeviceCapabilityExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Capability Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const DeviceCapabilityScreen(),
    );
  }
}

class DeviceCapabilityScreen extends StatelessWidget {
  const DeviceCapabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dc = DeviceCapability.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Device Capability Demo'), elevation: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Performance Overview Card
            _buildCard(
              title: 'Performance Overview',
              children: [
                _buildInfoRow('Platform', dc.platform.name.toUpperCase()),
                _buildInfoRow('Performance Score', '${dc.performanceScore.toStringAsFixed(1)}/100'),
                _buildInfoRow('Performance Tier', dc.performanceTier.name.toUpperCase()),
                _buildInfoRow('Description', dc.capabilityDescription),
              ],
            ),
            const SizedBox(height: 16),

            // Tier Information Card
            _buildCard(
              title: 'Tier Classifications',
              children: [
                _buildInfoRow('Memory Tier', dc.memoryTier.name.toUpperCase()),
                _buildInfoRow('Storage Tier', dc.storageTier.name.toUpperCase()),
                _buildInfoRow('Thermal Tier', dc.thermalTier.name.toUpperCase()),
              ],
            ),
            const SizedBox(height: 16),

            // Device Flags Card
            _buildCard(
              title: 'Device Characteristics',
              children: [
                _buildInfoRow('Low End Device', dc.isLowEnd ? 'Yes' : 'No'),
                _buildInfoRow('Mid Range Device', dc.isMidRange ? 'Yes' : 'No'),
                _buildInfoRow('High End Device', dc.isHighEnd ? 'Yes' : 'No'),
                _buildInfoRow('Thermal Throttling', dc.isThermalThrottling ? 'Yes' : 'No'),
                _buildInfoRow('Memory Limited', dc.isMemoryLimited ? 'Yes' : 'No'),
                _buildInfoRow('Storage Limited', dc.isStorageLimited ? 'Yes' : 'No'),
              ],
            ),
            const SizedBox(height: 16),

            // Recommendations Card
            _buildCard(
              title: 'Optimization Recommendations',
              children: [
                _buildInfoRow('Reduce Animations', dc.shouldReduceAnimations ? 'Yes' : 'No'),
                _buildInfoRow('Disable Heavy Graphics', dc.shouldDisableHeavyGraphics ? 'Yes' : 'No'),
                _buildInfoRow('Use Compressed Images', dc.shouldUseCompressedImages ? 'Yes' : 'No'),
                _buildInfoRow('Limit Video Quality', dc.shouldLimitVideoQuality ? 'Yes' : 'No'),
                _buildInfoRow('Enable Aggressive Caching', dc.shouldEnableAggressiveCaching ? 'Yes' : 'No'),
                _buildInfoRow('Limit Background Tasks', dc.shouldLimitBackgroundTasks ? 'Yes' : 'No'),
                _buildInfoRow('Performance Mode', dc.shouldEnablePerformanceMode ? 'Enabled' : 'Disabled'),
                _buildInfoRow('Recommended Frame Rate', '${dc.recommendedFrameRate} FPS'),
                _buildInfoRow('Concurrent Requests', '${dc.recommendedConcurrentRequests}'),
                _buildInfoRow('List Virtualization Threshold', '${dc.recommendedListThreshold} items'),
                _buildInfoRow('Image Cache Size', '${dc.recommendedImageCacheSizeMB} MB'),
              ],
            ),
            const SizedBox(height: 16),

            // Raw Data Card
            _buildCard(
              title: 'Raw Device Information',
              children: [
                if (dc.rawInfo.cpuCores != null) _buildInfoRow('CPU Cores', '${dc.rawInfo.cpuCores}'),
                if (dc.rawInfo.totalRamBytes != null)
                  _buildInfoRow(
                    'Total RAM',
                    '${(dc.rawInfo.totalRamBytes! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB',
                  ),
                if (dc.rawInfo.usedRamBytes != null && dc.rawInfo.totalRamBytes != null)
                  _buildInfoRow(
                    'RAM Usage',
                    '${((dc.rawInfo.usedRamBytes! / dc.rawInfo.totalRamBytes!) * 100).toStringAsFixed(1)}%',
                  ),
                if (dc.rawInfo.totalStorageBytes != null)
                  _buildInfoRow(
                    'Total Storage',
                    '${(dc.rawInfo.totalStorageBytes! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB',
                  ),
                if (dc.rawInfo.freeStorageBytes != null)
                  _buildInfoRow(
                    'Free Storage',
                    '${(dc.rawInfo.freeStorageBytes! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB',
                  ),
                if (dc.rawInfo.deviceModel != null) _buildInfoRow('Device Model', dc.rawInfo.deviceModel!),
                if (dc.rawInfo.sdkLevel != null) _buildInfoRow('Android SDK', '${dc.rawInfo.sdkLevel}'),
                if (dc.rawInfo.lowPowerModeEnabled != null)
                  _buildInfoRow('Low Power Mode', dc.rawInfo.lowPowerModeEnabled! ? 'Enabled' : 'Disabled'),
                if (dc.rawInfo.batteryLevel != null)
                  _buildInfoRow('Battery Level', '${(dc.rawInfo.batteryLevel! * 100).toStringAsFixed(0)}%'),
                if (dc.rawInfo.isCharging != null) _buildInfoRow('Charging', dc.rawInfo.isCharging! ? 'Yes' : 'No'),
                if (dc.rawInfo.processorFrequency != null)
                  _buildInfoRow('Max CPU Frequency', '${dc.rawInfo.processorFrequency} MHz'),
                if (dc.rawInfo.screenWidth != null && dc.rawInfo.screenHeight != null)
                  _buildInfoRow(
                    'Screen Resolution',
                    '${dc.rawInfo.screenWidth!.toInt()} × ${dc.rawInfo.screenHeight!.toInt()}',
                  ),
                if (dc.rawInfo.screenDensity != null)
                  _buildInfoRow('Screen Density', '${dc.rawInfo.screenDensity!.toStringAsFixed(2)}x'),
              ],
            ),

            const SizedBox(height: 32),

            // Warning message if needed
            if (dc.shouldShowPerformanceWarning)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Device is experiencing performance constraints. '
                        'Consider reducing app workload.',
                        style: TextStyle(color: Colors.orange.shade900),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
