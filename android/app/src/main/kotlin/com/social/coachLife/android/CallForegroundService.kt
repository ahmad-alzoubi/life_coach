package com.social.coachLife.android

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

/**
 * Foreground service used to keep Agora calls alive while the application is in the background.
 * The service displays a persistent notification so the system keeps the process alive.
 */
class CallForegroundService : Service() {

    override fun onBind(intent: Intent?) = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val title = intent?.getStringExtra(EXTRA_TITLE) ?: getString(R.string.app_name)
        val content =
            intent?.getStringExtra(EXTRA_CONTENT) ?: getString(R.string.call_in_progress_notification)

        val includeCamera = intent?.getBooleanExtra(EXTRA_INCLUDE_CAMERA, false) == true
        val notification = buildNotification(title, content)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val serviceType =
                if (includeCamera) {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE or ServiceInfo.FOREGROUND_SERVICE_TYPE_CAMERA
                } else {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
                }
            startForeground(NOTIFICATION_ID, notification, serviceType)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        // Keep running until the system explicitly stops the service.
        return START_STICKY
    }

    override fun onDestroy() {
        stopForeground(STOP_FOREGROUND_REMOVE)
        super.onDestroy()
    }

    private fun buildNotification(title: String, content: String): Notification {
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            flags,
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(content)
            .setStyle(NotificationCompat.BigTextStyle().bigText(content))
            .setSmallIcon(R.drawable.ic_stat_ic_notification)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            getString(R.string.call_notification_channel_name),
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = getString(R.string.call_notification_channel_description)
            setShowBadge(false)
        }

        val manager = NotificationManagerCompat.from(this)
        manager.createNotificationChannel(channel)
    }

    companion object {
        const val CHANNEL_ID = "active_call_channel"
        const val NOTIFICATION_ID = 9021
        const val EXTRA_TITLE = "extra_notification_title"
        const val EXTRA_CONTENT = "extra_notification_content"
        const val EXTRA_INCLUDE_CAMERA = "extra_include_camera"

        fun start(context: Context, title: String?, content: String?, includeCamera: Boolean) {
            val intent = Intent(context, CallForegroundService::class.java).apply {
                putExtra(EXTRA_TITLE, title)
                putExtra(EXTRA_CONTENT, content)
                putExtra(EXTRA_INCLUDE_CAMERA, includeCamera)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, CallForegroundService::class.java))
        }
    }
}
