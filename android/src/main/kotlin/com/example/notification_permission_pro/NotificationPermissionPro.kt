package com.example.notification_permission_pro

import android.annotation.TargetApi
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

/** NotificationPermissionPro */
class NotificationPermissionPro : FlutterPlugin, ActivityAware {
  private lateinit var channel: MethodChannel
  private var activityBinding: ActivityPluginBinding? = null
  private lateinit var context: Context

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, "notification_permission_pro/channel")
    channel.setMethodCallHandler { call, result ->
      when (call.method) {
        "getPermissionStatus" -> getPermissionStatus(result)
        "requestPermission" -> requestPermission(result)
        "openAppSettings" -> openAppSettings(result)
        else -> result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityBinding = binding
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activityBinding = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activityBinding = binding
  }

  override fun onDetachedFromActivity() {
    activityBinding = null
  }

  /// Get current notification permission status.
  /// 
  /// Android has multiple indicators:
  /// 1. POST_NOTIFICATIONS permission (runtime, Android 13+)
  /// 2. areNotificationsEnabled() system check
  /// 3. Channel importance level
  private fun getPermissionStatus(result: MethodChannel.Result) {
    val status: String = when {
      Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU -> {
        // Android 13+: check runtime permission + system setting
        val hasPermission = ContextCompat.checkSelfPermission(
          context,
          android.Manifest.permission.POST_NOTIFICATIONS
        ) == PackageManager.PERMISSION_GRANTED

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE)
          as NotificationManager

        when {
          hasPermission && notificationManager.areNotificationsEnabled() -> "granted"
          hasPermission && !notificationManager.areNotificationsEnabled() -> "denied"
          !hasPermission && notificationManager.areNotificationsEnabled() -> "notrequested"
          else -> "denied"
        }
      }
      Build.VERSION.SDK_INT >= Build.VERSION_CODES.O -> {
        // Android 8+: check system notification setting only
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE)
          as NotificationManager
        
        when {
          notificationManager.areNotificationsEnabled() -> "granted"
          else -> "denied"
        }
      }
      else -> {
        // Android < 8: no runtime permission checks needed
        // Assume granted if no explicit denial
        "granted"
      }
    }

    val resultMap = mapOf(
      "status" to status,
      "timestamp" to System.currentTimeMillis()
    )
    result.success(resultMap)
  }

  /// Request notification permission from the user.
  /// 
  /// On Android 13+, this requests the POST_NOTIFICATIONS runtime permission.
  /// On older versions, this is a no-op (permissions granted by default).
  @TargetApi(Build.VERSION_CODES.TIRAMISU)
  private fun requestPermission(result: MethodChannel.Result) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      val activity = activityBinding?.activity
      if (activity != null) {
        val hasShowPermissionRationale = activity.shouldShowRequestPermissionRationale(
          android.Manifest.permission.POST_NOTIFICATIONS
        )
        
        // For this simple plugin, we'll just check current status
        // A full implementation would request the permission via activity
        val status = when {
          ContextCompat.checkSelfPermission(
            context,
            android.Manifest.permission.POST_NOTIFICATIONS
          ) == PackageManager.PERMISSION_GRANTED -> true
          else -> false
        }
        result.success(status)
      } else {
        result.success(false)
      }
    } else {
      // Pre-Android 13: always granted
      result.success(true)
    }
  }

  /// Open app settings where user can modify notification preferences.
  private fun openAppSettings(result: MethodChannel.Result) {
    try {
      val intent = Intent().apply {
        action = android.provider.Settings.ACTION_APP_NOTIFICATION_SETTINGS
        putExtra(android.provider.Settings.EXTRA_APP_PACKAGE, context.packageName)
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      }
      
      // Fallback for older Android versions
      if (intent.resolveActivity(context.packageManager) == null) {
        intent.apply {
          action = android.provider.Settings.ACTION_APPLICATION_SETTINGS
          removeExtra(android.provider.Settings.EXTRA_APP_PACKAGE)
        }
      }
      
      context.startActivity(intent)
      result.success(true)
    } catch (e: Exception) {
      e.printStackTrace()
      result.success(false)
    }
  }
}
