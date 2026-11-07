package com.nananeko.bend_planer

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.core.content.ContextCompat
import androidx.core.content.IntentCompat
import androidx.core.content.PackageManagerCompat
import androidx.core.content.UnusedAppRestrictionsConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createChannels()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HEALTH_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "unusedRestrictionsOn" -> readUnusedRestrictions(result)
                    "openNotificationSettings" -> {
                        startActivity(notificationSettingsIntent())
                        result.success(null)
                    }
                    "openUnusedRestrictionsSettings" -> {
                        startActivity(
                            IntentCompat.createManageUnusedAppRestrictionsIntent(this, packageName),
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // One channel per kind of push, so a member can silence one kind alone in
    // the phone settings. Creating an existing channel is a no-op. The ids must
    // match push_worker/src/message.js and the release push in CI.
    private fun createChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java)
        val channels = listOf(
            "gigs" to R.string.channel_gigs,
            "reminders" to R.string.channel_reminders,
            "tips" to R.string.channel_tips,
            "band" to R.string.channel_band,
            "reports" to R.string.channel_reports,
            "updates" to R.string.channel_updates,
        )
        for ((id, name) in channels) {
            manager.createNotificationChannel(
                NotificationChannel(id, getString(name), NotificationManager.IMPORTANCE_HIGH),
            )
        }
    }

    // Whether Android may hibernate the app once it goes unused for months.
    // Hibernation also stops FCM, and the band relies on these pushes.
    private fun readUnusedRestrictions(result: MethodChannel.Result) {
        val future = PackageManagerCompat.getUnusedAppRestrictionsStatus(this)
        future.addListener(
            {
                val status = try {
                    future.get()
                } catch (_: Exception) {
                    UnusedAppRestrictionsConstants.ERROR
                }
                result.success(status in RESTRICTED)
            },
            ContextCompat.getMainExecutor(this),
        )
    }

    private fun notificationSettingsIntent(): Intent =
        Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
            .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)

    private companion object {
        const val HEALTH_CHANNEL = "bend_planer/reminder_health"
        val RESTRICTED = setOf(
            UnusedAppRestrictionsConstants.API_30_BACKPORT,
            UnusedAppRestrictionsConstants.API_30,
            UnusedAppRestrictionsConstants.API_31,
        )
    }
}
