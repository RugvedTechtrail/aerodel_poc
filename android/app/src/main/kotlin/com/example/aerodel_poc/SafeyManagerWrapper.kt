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
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.Date

private fun Double.format(digits: Int) = "%.${digits}f".format(this)

class SafeyManagerWrapper(private val context: Context) :
    SafeyScannerCallback,
    SafeyErrorCallback,
    SafeyDeviceCallback,
    SafeyConnectionCallback,
    SafeyTrialCallback,
    SafeyTestTypeCallback,
    SafeyTestCallback {

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
        safeyLungManager = SafeyLungManager.init(person, context)!!
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
        try {
            channel.invokeMethod("onConnectionStatusChanged", isConnected)
        } catch (e: Exception) {
            println("Error sending connection status: $e")
        }
    }

    override fun enableTest() {
        println("Test enabled")
    }

    override fun getBatteryStatus(batteryStatus: String) {
        println("Battery status: $batteryStatus")
    }

    override fun error(safeyDeviceManagerInfoState: SafeyDeviceManagerInfoState, message: String) {
        println("Error: $safeyDeviceManagerInfoState, $message")
        try {
            channel.invokeMethod("onError", message)
        } catch (e: Exception) {
            println("Error sending error message: $e")
        }
    }

    override fun getBluetoothDevice(device: SafeySpirometerDevice) {
        println("Discovered device: $device")
        discoveredDevices.add(device)
        try {
            val deviceMap = mapOf(
                "name" to device.deviceName,
                "address" to device.bluetoothDevice.address
            )
            channel.invokeMethod("onDeviceDiscovered", deviceMap)
        } catch (e: Exception) {
            println("Error sending device discovery: $e")
        }
    }

    override fun lastConnectedDeviceFound(device: BluetoothDevice) {
        println("Last connected device found: $device")
        try {
            val deviceMap = mapOf(
                "name" to device.name,
                "address" to device.address
            )
            channel.invokeMethod("onLastConnectedDeviceFound", deviceMap)
        } catch (e: Exception) {
            println("Error sending last connected device: $e")
        }
    }

    override fun getTestType(device: SafeySpirometerDevice, availableTestType: Array<Constants.TestType>) {
        println("Test type: $availableTestType")
        try {
            val testTypes = availableTestType.map { it.name }
            channel.invokeMethod("onTestTypeDiscovered", testTypes)
        } catch (e: Exception) {
            println("Error sending test types: $e")
        }
    }

    override fun selectTestType(): Constants.TestType {
        return Constants.TestType.FEVC
    }

    override fun enableTrial() {
        try {
            safeyLungManager.startTrial()
            Toast.makeText(context, "Trial started", Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            println("Error starting trial: $e")
            Toast.makeText(context, "Error starting trial", Toast.LENGTH_SHORT).show()
        }
    }

    fun startTestSession() {
        try {
            Toast.makeText(context, "Trial session started", Toast.LENGTH_SHORT).show()
            safeyLungManager.startTestSession(null)
        } catch (e: Exception) {
            println("Error starting test session: $e")
            Toast.makeText(context, "Error starting test session", Toast.LENGTH_SHORT).show()
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
        val currentYear = Date().year + 1900
        val birthYear = dateOfBirth.year + 1900
        val age = currentYear - birthYear

        val fileName = "${firstName}_${lastName}_${age}_${gender.name}_${heightInCentimeters}_${weightInKg}.txt"
        val filePath = externalDir.absolutePath + "/" + fileName
        val file = File(filePath)

        try {
            file.bufferedWriter().use { writer ->
                // Write patient information
                writer.write("Patient Information:\n")
                writer.write("------------------\n")
                writer.write("Name: $firstName $lastName\n")
                writer.write("Age: $age\n")
                writer.write("Gender: ${gender.name}\n")
                writer.write("Height: $heightInCentimeters cm\n")
                writer.write("Weight: $weightInKg kg\n\n")

                // Write test summary
                writer.write("Test Summary:\n")
                writer.write("-------------\n")
                testResult.preTestSessionResults?.let { sessionResults ->
                    writer.write("Best Trial Number: ${sessionResults.bestTrialNumber}\n")
                    writer.write("Suggested Diagnosis: ${sessionResults.suggestedDiagnosis ?: "Not Available"}\n")
                    writer.write("Session Score: ${sessionResults.sessionScore}\n")
                    writer.write("FEV1 Variance: ${sessionResults.FEV1Variance}\n")
                    writer.write("FVC Variance: ${sessionResults.FVCVariance}\n\n")

                    // Write detailed trial results
                    writer.write("Trial Results:\n")
                    writer.write("--------------\n")
                    sessionResults.trialsList?.forEach { (trialNumber, trial) ->
                        writer.write("Trial $trialNumber:\n")
                        
                        // Calculate key metrics from flow array
 val flowArray = trial.flowArray
                        if (flowArray != null && flowArray.isNotEmpty()) {
                            val maxFlow = flowArray.maxOf { it }
                            val avgFlow = flowArray.sum() / flowArray.size
                            
                            writer.write("Peak Flow: ${maxFlow.format(2)} L/s\n")
                            writer.write("Average Flow: ${avgFlow.format(2)} L/s\n")
                            
                            // Sample flow values at key points
                            writer.write("\nFlow Samples (L/s):\n")
                            val samplePoints = listOf(0.0, 0.25, 0.5, 0.75, 1.0, 2.0, 3.0)
                            samplePoints.forEach { second ->
                                val index = (second * (flowArray.size / 3.0)).toInt()
                                if (index < flowArray.size) {
                                    writer.write("${second.format(1)}s: ${flowArray[index].format(2)} L/s\n")
                                }
                            }
                        } else {
                            writer.write("No flow data available\n")
                        }
                        writer.write("\n")
                    }
                } ?: writer.write("No test session results available\n\n")
            }
            
            println("File written to: $filePath")
            Toast.makeText(context, "File created at $filePath", Toast.LENGTH_SHORT).show()
            channel.invokeMethod("onTestFileGenerated", filePath)

        } catch (e: Exception) {
            println("Error writing to file: $e")
            channel.invokeMethod("onError", "Failed to save test results: ${e.message}")
        }
    }

    override fun invalidManeuver(trialCount: Int) {
        println("Invalid maneuver")
        try {
            channel.invokeMethod("onInvalidManeuver", trialCount)
        } catch (e: Exception) {
            println("Error sending invalid maneuver: $e")
        }
    }

    override fun onProgressChange(
        progress: Double,
        flow: ArrayList<Double>,
        volume: ArrayList<Double>,
        time: ArrayList<Double>
    ) {
        try {
            val latestFlow = flow.lastOrNull() ?: 0.0
            val latestVolume = volume.lastOrNull() ?: 0.0
            val latestTime = time.lastOrNull() ?: 0.0

            val progressData = mapOf(
                "progress" to progress,
                "flow" to latestFlow,
                "volume" to latestVolume,
                "time" to latestTime,
                "flowArray" to ArrayList(flow),
                "volumeArray" to ArrayList(volume),
                "timeArray" to ArrayList(time)
            )
            
            channel.invokeMethod("onProgressUpdate", progressData)
        } catch (e: Exception) {
            println("Error sending progress update: $e")
        }
    }

    override fun testCompleted() {
        println("Test completed")
        try {
            Toast.makeText(context, "Test completed", Toast.LENGTH_SHORT).show()
            channel.invokeMethod("onTestCompleted", null)
        } catch (e: Exception) {
            println("Error sending test completion: $e")
        }
    }

    fun dispose() {
        safeyLungManager.unregisterCallbacks()
    }

    fun isConnected(): Boolean {
        return safeyLungManager.isConnected()
    }

    fun scanDevices() {
        try {
            initSafeyLungManager()
            discoveredDevices.clear()
            safeyLungManager.scanDevice()
        } catch (e: Exception) {
            println("Error scanning devices: $e")
            channel.invokeMethod("onError", "Failed to scan devices: ${e.message}")
        }
    }

    fun connectToDevice() {
        try {
            val device = discoveredDevices.firstOrNull()
            device?.let {
                safeyLungManager.connectDevice(it)
            } ?: run {
                channel.invokeMethod("onError", "No device found to connect")
            }
        } catch (e: Exception) {
            println("Error connecting to device: $e")
            channel.invokeMethod("onError", "Failed to connect: ${e.message}")
        }
    }

    fun disconnectDevice() {
        try {
            safeyLungManager.disconnect()
        } catch (e: Exception) {
            println("Error disconnecting device: $e")
            channel.invokeMethod("onError", "Failed to disconnect: ${e.message}")
        }
    }

    fun setFirstName(firstName: String?) {
        this.firstName = firstName ?: this.firstName
        println("First Name: $firstName")
        Toast.makeText(context, "First name set: $firstName", Toast.LENGTH_SHORT).show()
    }

    fun setLastName(lastName: String?) {
        this.lastName = lastName ?: this.lastName
        println("Last Name: $lastName")
        Toast.makeText(context, "Last name set: $lastName", Toast.LENGTH_SHORT).show()
    }

    fun setGender(gender: String?) {
        this.gender = when (gender?.toLowerCase()) {
            "male" -> Constants.Gender.Male
            "female" -> Constants.Gender.Female
            else -> this.gender
        }
        println("Gender: $gender")
        Toast.makeText(context, "Gender set: $gender", Toast.LENGTH_SHORT).show()
    }

    fun setDateOfBirth(year: Int?, month: Int?, day: Int?) {
        if (year != null && month != null && day != null) {
            this.dateOfBirth = Date(year - 1900, month - 1, day)
        }
        println("Date of Birth: $year-$month-$day")
        Toast.makeText(context, "Date of birth set: $year-$month-$day", Toast.LENGTH_SHORT).show()
    }

    fun setHeight(height: Int?) {
        this.heightInCentimeters = height ?: this.heightInCentimeters
        println("Height: $height cm")
        Toast.makeText(context, "Height set: $height", Toast.LENGTH_SHORT).show()
    }

    fun setWeight(weight: Int?) {
        this.weightInKg = weight?.toDouble() ?: this.weightInKg
        println("Weight: $weight kg")
        Toast.makeText(context, "Weight set: $weight", Toast.LENGTH_SHORT).show()
    }
}