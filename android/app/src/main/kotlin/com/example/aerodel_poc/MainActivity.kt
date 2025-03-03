package com.example.aerodel_poc

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private lateinit var safeyManagerWrapper: SafeyManagerWrapper
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        safeyManagerWrapper = SafeyManagerWrapper(context)
        val backgroundChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "background_poc_safey")
        safeyManagerWrapper.channel = backgroundChannel
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "poc_safey").setMethodCallHandler { call, result ->
            when (call.method) {
                "getConnected" -> {
                    result.success(safeyManagerWrapper.isConnected())
                }
                "scanDevices" -> {
                    safeyManagerWrapper.scanDevices()
                    result.success(null)
                }
                "connectDevice" -> {
                    safeyManagerWrapper.connectToDevice()
                    result.success(null)
                }
                "disconnectDevice" -> {
                    safeyManagerWrapper.disconnectDevice()
                    result.success(null)
                }
                "startTrial" -> {
                    safeyManagerWrapper.startTestSession()
                    safeyManagerWrapper.enableTrial()
                    result.success(null)
                }
                "stopTrial" -> {
                    safeyManagerWrapper.stopTest()
                    result.success(null)
                }
                "setFirstName" -> {
                    val firstName = call.argument<String>("firstName")
                    safeyManagerWrapper.setFirstName(firstName)
                    result.success(null)
                }
                "setLastName" -> {
                    val lastName = call.argument<String>("lastName")
                    safeyManagerWrapper.setLastName(lastName)
                    result.success(null)
                }
                "setGender" -> {
                    val gender = call.argument<String>("gender")
                    safeyManagerWrapper.setGender(gender)
                    result.success(null)
                }
                "setDateOfBirth" -> {
                    val year = call.argument<Int>("year")
                    val month = call.argument<Int>("month")
                    val day = call.argument<Int>("day")
                    safeyManagerWrapper.setDateOfBirth(year, month, day)
                    result.success(null)
                }
                "setHeight" -> {
                    val height = call.argument<Int>("height")
                    safeyManagerWrapper.setHeight(height)
                    result.success(null)
                }
                "setWeight" -> {
                    val weight = call.argument<Int>("weight")
                    safeyManagerWrapper.setWeight(weight)
                    result.success(null)
                }
                "getBatteryStatus" -> {
                    // Added method to manually get battery status if needed
                    result.success("N/A") // The actual status is sent via callback
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}