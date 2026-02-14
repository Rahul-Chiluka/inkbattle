package com.inkbattle.app

import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowInsetsController
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Use edge-to-edge for Android 15+ (API 35+) to avoid deprecated API warnings
        // This helps mitigate warnings from Flutter's internal use of deprecated APIs
        if (Build.VERSION.SDK_INT >= 35) {
            WindowCompat.setDecorFitsSystemWindows(window, false)
            val insetsController = window.insetsController
            if (insetsController != null) {
                insetsController.systemBarsBehavior = 
                    WindowInsetsController.BEHAVIOR_DEFAULT
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.inkbattle.app/native_log")
            .setMethodCallHandler { call, result ->
                if (call.method == "log") {
                    @Suppress("UNCHECKED_CAST")
                    val args = call.arguments as? Map<String, Any?>
                    val message = args?.get("message") as? String ?: ""
                    val tag = args?.get("tag") as? String ?: "InkBattle"
                    val level = (args?.get("level") as? String)?.lowercase() ?: "info"
                    when (level) {
                        "error" -> Log.e(tag, message)
                        "warning" -> Log.w(tag, message)
                        "debug" -> Log.d(tag, message)
                        else -> Log.i(tag, message)
                    }
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
