package com.example.aerodel_poc

import android.bluetooth.BluetoothDevice
import android.content.Context
import android.content.pm.PackageManager
import android.os.Environment
import android.widget.Toast
import com.safey.safeysdk.callbacks.*
import com.safey.safeysdk.classes.SafeyLungManager
import com.safey.safeysdk.model.SafeyPerson
import com.safey.safeysdk.model.SafeySpirometerDevice
import com.safey.safeysdk.model.TestResultsModel
import com.safey.safeysdk.utils.Constants
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.File
import java.util.Date
import java.util.Timer

class SafeyManagerWrapper(private val context: Context) :
    SafeyScannerCallback,
    SafeyErrorCallback,
    SafeyDeviceCallback,
    SafeyConnectionCallback,
    SafeyTrialCallback,
    SafeyTestTypeCallback,
    SafeyTestCallback
      {

    private lateinit var safeyLungManager: SafeyLungManager
    private val discoveredDevices = mutableListOf<SafeySpirometerDevice>()
    internal lateinit var channel: MethodChannel
    private lateinit var testResultsModel: TestResultsModel

     private var firstName: String = "John"
    private var lastName: String = "Doe"
    private var gender: Constants.Gender = Constants.Gender.Male
    private var dateOfBirth: Date = Date(1993, 1, 1)
    private var heightInCentimeters: Int = 180
    private var weightInKg: Double = 90.0


    init {
        initSafeyLungManager()
    }

    fun initSafeyLungManager() {
        println("Initializing SafeyLungManager")
         // val person: SafeyPerson = SafeyPerson(
        //     "John",
        //     "Doe",
        //     Constants.Gender.Male,
        //     Constants.PredictionLibraries.CHHABRA,
        //     Constants.Ethnicity.Indian,
        //     dateOfBirth = Date(1993, 1, 1),
        //     heightInCentimeters = 180,
        //     weightInKg = 90.0,
        // )
        println("First Name: $firstName")
        println("Last Name: $lastName")
        println("Gender: $gender")
        println("Date of Birth: $dateOfBirth")
        println("Height: $heightInCentimeters")
        println("Weight: $weightInKg")


         val person = SafeyPerson(
            firstName,
            lastName,
            gender,
            Constants.PredictionLibraries.CHHABRA,
            Constants.Ethnicity.Indian,
            dateOfBirth = dateOfBirth,
            heightInCentimeters = heightInCentimeters,
            weightInKg = weightInKg,
        )
        safeyLungManager = SafeyLungManager.init( person, context)!!
        registerCallbacks()

        
    }

    private fun registerCallbacks() {
        println("Registering callbacks")
        safeyLungManager.apply {
            registerErrorCallback(this@SafeyManagerWrapper)
            registerDeviceCallback(this@SafeyManagerWrapper)
            registerConnectionCallback(this@SafeyManagerWrapper)
            registerTrialCallback(this@SafeyManagerWrapper)
            registerTestTypeCallback(this@SafeyManagerWrapper)
            registerScannerCallback(this@SafeyManagerWrapper)
            registerTestCallback(this@SafeyManagerWrapper)
        }
    }

    fun startTest(safeyPerson: SafeyPerson) {
        safeyLungManager.startTest(safeyPerson)
    }

    fun stopTest() {
        safeyLungManager.stopTrial()
    }

    override fun getConnected(isConnected: Boolean) {
        channel.invokeMethod("onConnectionStatusChanged", isConnected)
    }

    override fun enableTest() {
        println("Test enabled")
//        safeyLungManager.startTrial()
    }

    override fun getBatteryStatus(batteryStatus: String) {
        println("Battery status: $batteryStatus")
    }

    override fun error(safeyDeviceManagerInfoState: SafeyDeviceManagerInfoState, message: String) {
        println("Error: $safeyDeviceManagerInfoState, $message")
    }

    override fun getBluetoothDevice(device: SafeySpirometerDevice) {
        println("Discovered devices: $device")

        discoveredDevices.add(device)
        val deviceMap = mapOf(
            "name" to device.deviceName,
            "address" to device.bluetoothDevice.address
        )
        channel.invokeMethod("onDeviceDiscovered", deviceMap)
    }

    override fun lastConnectedDeviceFound(device: BluetoothDevice) {
        println("Last connected device found: $device")

        val deviceMap = mapOf(
            "name" to device.name,
            "address" to device.address
        )
        channel.invokeMethod("onLastConnectedDeviceFound", deviceMap)
    }

    override fun getTestType(
        device: SafeySpirometerDevice,
        availableTestType: Array<Constants.TestType>
    ) {
        println("Test type: $availableTestType")
        val testTypes = availableTestType.map { it.name }
        channel.invokeMethod("onTestTypeDiscovered", testTypes)
    }

    override fun selectTestType(): Constants.TestType {
        return Constants.TestType.FEVC
    }

    override fun enableTrial() {
//        getTestType(device = discoveredDevices.first(), availableTestType = arrayOf(Constants.TestType.FEVC, Constants.TestType.FVL))
//        selectTestType()
//        Timer().schedule(object : java.util.TimerTask() {
//            override fun run() {
                safeyLungManager.startTrial()
        Toast.makeText(context, "Trial started", Toast.LENGTH_SHORT).show()
//            }
//        }, 1000)
//        safeyLungManager.startTrial()
    }

          fun startTestSession() {
              Toast.makeText(context, "Trial session started", Toast.LENGTH_SHORT).show()
              safeyLungManager.startTestSession(null);
          }

    fun dispose() {
        safeyLungManager.unregisterCallbacks()
    }

    fun isConnected(): Boolean {
        return safeyLungManager.isConnected()
    }

    fun scanDevices() {
        initSafeyLungManager()
        discoveredDevices.clear()
        safeyLungManager.scanDevice()
    }

    fun connectToDevice() {
        val device = discoveredDevices.first()
//        find { it.bluetoothDevice.address == address }
        device.let {
            safeyLungManager.connectDevice(it)
        } ?: run {
            channel.invokeMethod("onError", "Device not found")
        }
    }

    override fun getTestResult(testResult: TestResultsModel, trialCount: Int) {
        println("Test result: $testResult, trial count: $trialCount")
        testResultsModel = testResult
    }

    override fun getTestResults(testResult: TestResultsModel) {
        println("Test results: $testResult")
        testResultsModel = testResult

        val externalDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)

         // Calculate age
    val currentYear = Date().year + 1900
    val birthYear = dateOfBirth.year + 1900
    val age = currentYear - birthYear

         val fileName = "${firstName}_${lastName}_${age}_${gender.name}_${heightInCentimeters}_${weightInKg}.txt"
        val filePath = externalDir.absolutePath + "/" + fileName
        val file = File(filePath)

        try {
            val fileWriter = file.bufferedWriter()
//            convert to json and write to file
            fileWriter.use {
                it.write("Test results: $testResult")
//                testResult.to()
            }
            println("file written to: $filePath")
            Toast.makeText(context, "File created at $filePath", Toast.LENGTH_SHORT).show()

        } catch (e: Exception) {
            println("Error writing to file: $e")
        }
    }



    override fun invalidManeuver(trialCount: Int) {
        println("Invalid maneuver")
    }

    override fun onProgressChange(
        progress: Double,
        flow: ArrayList<Double>,
        volume: ArrayList<Double>,
        time: ArrayList<Double>
    ) {
        val latestFlow = flow.lastOrNull() ?: 0.0
        val latestVolume = volume.lastOrNull() ?: 0.0
        val latestTime = time.lastOrNull() ?: 0.0
    
        println("Progress: $progress, Latest flow: $latestFlow, Latest volume: $latestVolume, Latest time: $latestTime")
        
    }

    override fun testCompleted() {
        println("Test completed")
        Toast.makeText(context, "Test completed", Toast.LENGTH_SHORT).show()

    }

    fun disconnectDevice() {
        safeyLungManager.disconnect()
    }

     fun setFirstName(firstName: String?) {
        this.firstName = firstName ?: this.firstName
        println("First Name: $firstName")
         Toast.makeText(context, "first name set: $firstName", Toast.LENGTH_SHORT).show()

     }

    fun setLastName(lastName: String?) {
        this.lastName = lastName ?: this.lastName
        println("Last Name: $lastName")
        Toast.makeText(context, "last name set: $lastName", Toast.LENGTH_SHORT).show()
    }

    fun setGender(gender: String?) {
        this.gender = when (gender?.toLowerCase()) {
            "male" -> Constants.Gender.Male
            "female" -> Constants.Gender.Female
            else -> this.gender
        }
        println("Gender: $gender")
        Toast.makeText(context, "gender set: $gender", Toast.LENGTH_SHORT).show()
    }

    fun setDateOfBirth(year: Int?, month: Int?, day: Int?) {
        if (year != null && month != null && day != null) {
            this.dateOfBirth = Date(year - 1900, month - 1, day)
        }
        println("Date of Birth: $year-$month-$day")
        Toast.makeText(context, "date of birth set: $year-$month-$day", Toast.LENGTH_SHORT).show()
    }

    fun setHeight(height: Int?) {
        this.heightInCentimeters = height ?: this.heightInCentimeters
        println("Height: $height cm")
        Toast.makeText(context, "height set: $height", Toast.LENGTH_SHORT).show()
    }

    fun setWeight(weight: Int?) {
        this.weightInKg = weight?.toDouble() ?: this.weightInKg
        println("Weight: $weight kg")
        Toast.makeText(context, "weight set: $weight", Toast.LENGTH_SHORT).show()
    }


    // Add other methods to interact with SafeyLungManager as needed
}
