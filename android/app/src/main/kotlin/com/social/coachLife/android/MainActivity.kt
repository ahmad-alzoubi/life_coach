package com.social.coachLife.android

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.tiktok.TikTokBusinessSdk
import com.tiktok.TikTokBusinessSdk.TTConfig

class MainActivity : FlutterActivity() {

    private val CHANNEL = "tiktok_events"
    private val CALL_CHANNEL = "com.social.coachLife.android/call_service"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val ttConfig = TTConfig(applicationContext).apply {
            setAppId("com.social.coachLife.android") // your app package name
            setTTAppId("7524648145117626375") // TikTok App ID from Events Manager
            enableAutoIapTrack()
        }

        TikTokBusinessSdk.initializeSdk(ttConfig)
        TikTokBusinessSdk.startTrack()
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up MethodChannel for Flutter <-> Native bridge
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "trackEvent" -> {
                    val eventName = call.argument<String>("event")
                    if (eventName != null) {
                        try {
                            // TikTok Ads SDK custom event tracking
                            TikTokBusinessSdk.trackEvent(eventName)
                            println("Tracking TikTok event: $eventName")
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("TRACK_EVENT_ERROR", "Failed to track event: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Event name is null", null)
                    }
                }
                "identify" -> {
                    val externalId = call.argument<String>("userId")
                    val externalUserName = call.argument<String>("userName")
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val email = call.argument<String>("email")

                    try {
                        TikTokBusinessSdk.identify(externalId, externalUserName, phoneNumber, email)
                        println("TikTok identify called with externalId: $externalId")
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("IDENTIFY_ERROR", "Failed to identify user: ${e.message}", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CALL_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val title = call.argument<String>("title")
                    val content = call.argument<String>("content")
                    val includeCamera = call.argument<Boolean>("includeCamera") ?: false
                    CallForegroundService.start(this, title, content, includeCamera)
                    result.success(null)
                }
                "stopService" -> {
                    CallForegroundService.stop(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
