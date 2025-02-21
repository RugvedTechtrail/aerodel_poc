import 'dart:async';

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
  final pocSafey = PocSafey();

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

  final RxInt elapsedSeconds = 0.obs;
  final RxBool isTimerRunning = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    initializeConnection();
    setupListeners();
  }

  Future<void> initializeConnection() async {
    try {
      final connected = await pocSafey.getConnected(); // Changed from _pocSafey
      isConnected.value = connected ?? false;
    } catch (e) {
      handleError('Failed to initialize connection: $e');
    }
  }

  void setupListeners() {
    pocSafey.onDeviceDiscovered = (device) {
      devices.add(device);
    };

    pocSafey.onProgressUpdate = (progressData) {
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

    pocSafey.onError = (error) {
      handleError(error);
    };

    pocSafey.onTestFileGenerated = (String filePath) {
      lastGeneratedFilePath.value = filePath;
      isTestCompleted.value = true;
      isTesting.value = false;
      stopTimer(); // Stop the timer when test is completed NEW

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
      await pocSafey.scanDevices();
    } catch (e) {
      handleError('Failed to scan devices: $e');
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> connectDevice() async {
    try {
      await pocSafey.connectDevice();
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
      await pocSafey.disconnectDevice();
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

      // Add timeout to connection check
      final isStillConnected = await pocSafey.getConnected().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Connection check timed out');
        },
      );

      if (isStillConnected != true) {
        throw Exception('Device is not connected');
      }

      isTesting.value = true;
      isTestCompleted.value = false;
      startTimer(); //NEW
      await pocSafey.startTrial();
    } on TimeoutException {
      handleError('Connection timeout. Please reconnect the device.');
      isTesting.value = false;
      isConnected.value = false;
    } catch (e) {
      handleError('Failed to start trial: $e');
      isTesting.value = false;
      stopTimer(); //NEW
    }
  }

  void startTimer() {
    elapsedSeconds.value = 0;
    isTimerRunning.value = true;
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds.value++;
    });
  }

  void stopTimer() {
    _timer?.cancel();
    isTimerRunning.value = false;
  }

  Future<void> updatePatientData() async {
    try {
      await pocSafey.setFirstName(firstName.value);
      await pocSafey.setLastName(lastName.value);
      await pocSafey.setGender(gender.value);
      await pocSafey.setDateOfBirth(dateOfBirth.value);
      await pocSafey.setHeight(height.value.toString());
      await pocSafey.setWeight(weight.value.toString());

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
    _timer?.cancel();
    // Clean up resources if needed
    super.onClose();
  }
}
