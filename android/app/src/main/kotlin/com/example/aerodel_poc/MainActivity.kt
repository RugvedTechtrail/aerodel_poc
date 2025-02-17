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
            // TODO
            when (call.method) {
                "getConnected" -> {
                    result.success(true)
                }
                "scanDevices" -> {
                    safeyManagerWrapper.scanDevices()
                }
                "connectDevice" -> {
            val device = call.argument<BluetoothDevice>("device")
                    safeyManagerWrapper.connectToDevice()
                }
                "disconnectDevice" -> {
                    safeyManagerWrapper.disconnectDevice()
                }
                "startTrial" -> {
                    safeyManagerWrapper.startTestSession()
            safeyManagerWrapper.enableTrial()
                }
                 "setFirstName" -> {
            val firstName = call.argument<String>("firstName")
            safeyManagerWrapper.setFirstName(firstName)
        }
        "setLastName" -> {
            val lastName = call.argument<String>("lastName")
            safeyManagerWrapper.setLastName(lastName)
        }
        "setGender" -> {
            val gender = call.argument<String>("gender")
            safeyManagerWrapper.setGender(gender)
        }
        "setDateOfBirth" -> {
            val year = call.argument<Int>("year")
            val month = call.argument<Int>("month")
            val day = call.argument<Int>("day")
            safeyManagerWrapper.setDateOfBirth(year, month, day)
        }
        "setHeight" -> {
            val height = call.argument<Int>("height")
            safeyManagerWrapper.setHeight(height)
        }
        "setWeight" -> {
            val weight = call.argument<Int>("weight")
            safeyManagerWrapper.setWeight(weight)
        }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}

















