package com.nrlngrsh.device_capability

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.PowerManager
import android.os.StatFs
import android.util.DisplayMetrics
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.RandomAccessFile

/** DeviceCapabilityPlugin */
class DeviceCapabilityPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "device_capability")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getDeviceInfo" -> {
        try {
          val deviceInfo = collectDeviceInfo()
          result.success(deviceInfo)
        } catch (e: Exception) {
          result.error("ERROR", "Failed to collect device info: ${e.message}", null)
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun collectDeviceInfo(): Map<String, Any?> {
    val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
    val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

    val memInfo = ActivityManager.MemoryInfo()
    activityManager.getMemoryInfo(memInfo)

    val totalRam = memInfo.totalMem
    val usedRam = totalRam - memInfo.availMem

    val cpuCores = getCpuCoreCount()
    val (totalStorage, freeStorage) = getStorageInfo()
    val thermalState = getThermalState()
    val batteryInfo = getBatteryInfo()
    val screenInfo = getScreenInfo(windowManager)

    return mapOf(
      "platform" to "android",
      "cpuCores" to cpuCores,
      "totalRamBytes" to totalRam,
      "usedRamBytes" to usedRam,
      "totalStorageBytes" to totalStorage,
      "freeStorageBytes" to freeStorage,
      "sdkLevel" to Build.VERSION.SDK_INT,
      "deviceModel" to "${Build.MANUFACTURER} ${Build.MODEL}",
      "thermalState" to thermalState,
      "lowPowerModeEnabled" to powerManager.isPowerSaveMode,
      "batteryLevel" to batteryInfo.first,
      "isCharging" to batteryInfo.second,
      "screenWidth" to screenInfo.first,
      "screenHeight" to screenInfo.second,
      "screenDensity" to screenInfo.third,
      "processorFrequency" to getMaxCpuFrequency()
    )
  }

  private fun getCpuCoreCount(): Int {
    return Runtime.getRuntime().availableProcessors()
  }

  private fun getStorageInfo(): Pair<Long, Long> {
    val stat = StatFs(Environment.getDataDirectory().path)
    val totalBytes = stat.blockCountLong * stat.blockSizeLong
    val freeBytes = stat.availableBlocksLong * stat.blockSizeLong
    return Pair(totalBytes, freeBytes)
  }

  private fun getThermalState(): Int {
    // Android doesn't provide direct thermal state API before Android Q
    // We return 0 (normal) as default
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
      return when (powerManager.currentThermalStatus) {
        PowerManager.THERMAL_STATUS_NONE -> 0
        PowerManager.THERMAL_STATUS_LIGHT -> 1
        PowerManager.THERMAL_STATUS_MODERATE -> 1
        PowerManager.THERMAL_STATUS_SEVERE -> 2
        PowerManager.THERMAL_STATUS_CRITICAL -> 3
        PowerManager.THERMAL_STATUS_EMERGENCY -> 3
        PowerManager.THERMAL_STATUS_SHUTDOWN -> 3
        else -> 0
      }
    }
    return 0
  }

  private fun getBatteryInfo(): Pair<Double, Boolean> {
    val batteryIntent = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    val level = batteryIntent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
    val scale = batteryIntent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
    val status = batteryIntent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1

    val batteryPct = if (level >= 0 && scale > 0) {
      level.toDouble() / scale.toDouble()
    } else {
      0.0
    }

    val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                     status == BatteryManager.BATTERY_STATUS_FULL

    return Pair(batteryPct, isCharging)
  }

  private fun getScreenInfo(windowManager: WindowManager): Triple<Double, Double, Double> {
    val metrics = DisplayMetrics()

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      val display = context.display
      display?.getRealMetrics(metrics)
    } else {
      @Suppress("DEPRECATION")
      windowManager.defaultDisplay.getRealMetrics(metrics)
    }

    return Triple(
      metrics.widthPixels.toDouble(),
      metrics.heightPixels.toDouble(),
      metrics.density.toDouble()
    )
  }

  private fun getMaxCpuFrequency(): Int? {
    try {
      var maxFreq = 0
      val numCores = getCpuCoreCount()

      for (i in 0 until numCores) {
        val file = File("/sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_max_freq")
        if (file.exists()) {
          val freq = file.readText().trim().toIntOrNull()
          if (freq != null && freq > maxFreq) {
            maxFreq = freq
          }
        }
      }

      // Convert from KHz to MHz
      return if (maxFreq > 0) maxFreq / 1000 else null
    } catch (e: Exception) {
      return null
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
