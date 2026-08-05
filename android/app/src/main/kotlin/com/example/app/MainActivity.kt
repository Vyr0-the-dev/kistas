package com.example.app

import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app/alarm"
    private var mediaPlayer: MediaPlayer? = null
    private val handler = Handler(Looper.getMainLooper())
    private var stopRunnable: Runnable? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    playAlarm()
                    result.success(null)
                }
                "stop" -> {
                    stopAlarm()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun playAlarm() {
        stopAlarm() // Stop previous if any
        try {
            // Play the custom EAS alarm from res/raw/alarm_custom.mp3
            val resId = resources.getIdentifier("alarm_custom", "raw", packageName)
            if (resId != 0) {
                mediaPlayer = MediaPlayer.create(applicationContext, resId).apply {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .build()
                    )
                    isLooping = true
                    start()
                }

                // Auto-stop after 15 seconds
                stopRunnable = Runnable {
                    stopAlarm()
                }
                handler.postDelayed(stopRunnable!!, 15000)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun stopAlarm() {
        stopRunnable?.let {
            handler.removeCallbacks(it)
            stopRunnable = null
        }

        mediaPlayer?.let {
            try {
                if (it.isPlaying) {
                    it.stop()
                }
                it.reset()
                it.release()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        mediaPlayer = null
    }
}