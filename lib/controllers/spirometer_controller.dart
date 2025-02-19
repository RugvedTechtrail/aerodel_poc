import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import '../package/poc_safey.dart';

class FlowVolumePoint {
  final double flow;
  final double volume;
  FlowVolumePoint(this.volume, this.flow);
}

class SpirometryController extends GetxController {
  final PocSafey _pocSafey = PocSafey();

  // Connection states
  final RxBool isConnected = false.obs;
  final RxBool isScanning = false.obs;
  final RxBool isTesting = false.obs;
  final RxList devices = [].obs;

  // Test progress values
  final RxDouble currentProgress = 0.0.obs;
  final RxDouble currentFlow = 0.0.obs;
  final RxDouble currentVolume = 0.0.obs;
  final RxDouble currentTime = 0.0.obs;

  // Test data arrays
  final RxList<double> flowArray = <double>[].obs;
  final RxList<double> volumeArray = <double>[].obs;
  final RxList<double> timeArray = <double>[].obs;

  // Test results
  final RxDouble peakFlow = 0.0.obs;
  final RxDouble fvc = 0.0.obs;
  final RxDouble fev1 = 0.0.obs;
  final RxString lastGeneratedFilePath = ''.obs;
  final RxBool isTestCompleted = false.obs;

  // Patient data
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString gender = ''.obs;
  final RxString dateOfBirth = ''.obs;
  final RxInt height = 0.obs;
  final RxInt weight = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initializeConnection();
    setupListeners();
  }

  Future<void> initializeConnection() async {
    try {
      final connected = await _pocSafey.getConnected();
      isConnected.value = connected ?? false;
    } catch (e) {
      handleError('Failed to initialize connection: $e');
    }
  }

  void setupListeners() {
    _pocSafey.onDeviceDiscovered = (device) {
      devices.add(device);
    };

    _pocSafey.onProgressUpdate = (progressData) {
      try {
        currentProgress.value = progressData['progress'] as double;
        currentFlow.value = progressData['flow'] as double;
        currentVolume.value = progressData['volume'] as double;
        currentTime.value = progressData['time'] as double;

        // Update arrays safely
        if (progressData['flowArray'] != null) {
          flowArray.value =
              List<double>.from(progressData['flowArray'] as List);
        }
        if (progressData['volumeArray'] != null) {
          volumeArray.value =
              List<double>.from(progressData['volumeArray'] as List);
        }
        if (progressData['timeArray'] != null) {
          timeArray.value =
              List<double>.from(progressData['timeArray'] as List);
        }

        // Calculate peak flow
        if (flowArray.isNotEmpty) {
          peakFlow.value =
              flowArray.reduce((curr, next) => curr > next ? curr : next);
        }

        // Update FVC (last volume reading)
        if (volumeArray.isNotEmpty) {
          fvc.value = volumeArray.last;
        }

        // Calculate FEV1 (volume at 1 second)
        if (timeArray.isNotEmpty && volumeArray.isNotEmpty) {
          final oneSecondIndex = timeArray.indexWhere((time) => time >= 1.0);
          if (oneSecondIndex != -1) {
            fev1.value = volumeArray[oneSecondIndex];
          }
        }
      } catch (e) {
        print('Error processing progress update: $e');
      }
    };

    _pocSafey.onError = (error) {
      handleError(error);
    };

    _pocSafey.onTestFileGenerated = (String filePath) {
      lastGeneratedFilePath.value = filePath;
      isTestCompleted.value = true;
      isTesting.value = false;

      Get.snackbar(
        'Test Completed',
        'Results saved successfully',
        mainButton: TextButton(
          onPressed: () => openTestFile(),
          child: const Text('Open File', style: TextStyle(color: Colors.white)),
        ),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    };
  }

  Future<bool> requestPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.storage,
      Permission.manageExternalStorage,
    ];

    for (final permission in permissions) {
      final status = await permission.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        handleError('Permission denied: ${permission.toString()}');
        return false;
      }
    }
    return true;
  }

  Future<void> scanDevices() async {
    try {
      if (!await requestPermissions()) return;

      isScanning.value = true;
      devices.clear();
      await _pocSafey.scanDevices();
    } catch (e) {
      handleError('Failed to scan devices: $e');
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> connectDevice() async {
    try {
      await _pocSafey.connectDevice();
      isConnected.value = true;
      Get.snackbar(
        'Success',
        'Device connected successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      handleError('Failed to connect device: $e');
    }
  }

  Future<void> disconnectDevice() async {
    try {
      await _pocSafey.disconnectDevice();
      isConnected.value = false;
      isTesting.value = false;
      isTestCompleted.value = false;

      // Reset all test values
      currentProgress.value = 0.0;
      currentFlow.value = 0.0;
      currentVolume.value = 0.0;
      currentTime.value = 0.0;
      flowArray.clear();
      volumeArray.clear();
      timeArray.clear();

      Get.snackbar(
        'Success',
        'Device disconnected successfully',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      handleError('Failed to disconnect device: $e');
    }
  }

  Future<void> startTrial() async {
    try {
      if (!isConnected.value) {
        throw Exception('Please connect to a device first');
      }
      isTesting.value = true;
      isTestCompleted.value = false;
      await _pocSafey.startTrial();
    } catch (e) {
      handleError('Failed to start trial: $e');
      isTesting.value = false;
    }
  }

  Future<void> updatePatientData() async {
    try {
      await _pocSafey.setFirstName(firstName.value);
      await _pocSafey.setLastName(lastName.value);
      await _pocSafey.setGender(gender.value);
      await _pocSafey.setDateOfBirth(dateOfBirth.value);
      await _pocSafey.setHeight(height.value.toString());
      await _pocSafey.setWeight(weight.value.toString());

      Get.snackbar(
        'Success',
        'Patient data updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      handleError('Failed to update patient data: $e');
    }
  }

  void openTestFile() {
    if (lastGeneratedFilePath.value.isNotEmpty) {
      OpenFile.open(lastGeneratedFilePath.value).then((result) {
        if (result.type != ResultType.done) {
          handleError('Failed to open file: ${result.message}');
        }
      });
    }
  }

  List<FlowVolumePoint> getFlowVolumePoints() {
    final points = <FlowVolumePoint>[];
    for (var i = 0; i < flowArray.length && i < volumeArray.length; i++) {
      points.add(FlowVolumePoint(volumeArray[i], flowArray[i]));
    }
    return points;
  }

  void handleError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}
