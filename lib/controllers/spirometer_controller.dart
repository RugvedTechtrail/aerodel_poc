import 'dart:async';
import 'dart:developer';

import 'package:aerodel_poc/Widgets/chartReport.dart';
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
  final reportGenerator =
      ReportGenerator(); // Create an instance of ReportGenerator
  final pocSafey = PocSafey();
  final RxString batteryStatus = ''.obs;
  // Connection states
  final RxBool isConnected = false.obs;
  final RxBool isScanning = false.obs;
  final RxBool isTesting = false.obs;
  final RxList devices = [].obs;
  RxBool isLoading = false.obs;

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
  final RxString lastGeneratedPdfPath = ''.obs;

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

    log('batter statsu in init is ${batteryStatus.value}');
    initializeConnection();
    setupListeners();
  }

  Future<void> initializeConnection() async {
    try {
      log('lengh on device in init is ${devices.length}');
      final connected = await pocSafey.getConnected(); // Changed from _pocSafey
      isConnected.value = connected ?? false;
    } catch (e) {
      handleError('Failed to initialize connection: $e');
    }
  }

  // void setupListeners() {
  //   pocSafey.onDeviceDiscovered = (device) {
  //     devices.add(device);
  //   };
  //   pocSafey.onProgressUpdate = (progressData) {
  //     try {
  //       log('progress data is $progressData');
  //       currentProgress.value = progressData['progress'] as double;
  //       currentFlow.value = progressData['flow'] as double;
  //       currentVolume.value = progressData['volume'] as double;
  //       currentTime.value = progressData['time'] as double;
  //       // Update arrays safely
  //       if (progressData['flowArray'] != null) {
  //         flowArray.value =
  //             List<double>.from(progressData['flowArray'] as List);
  //       }
  //       if (progressData['volumeArray'] != null) {
  //         volumeArray.value =
  //             List<double>.from(progressData['volumeArray'] as List);
  //       }
  //       if (progressData['timeArray'] != null) {
  //         timeArray.value =
  //             List<double>.from(progressData['timeArray'] as List);
  //       }
  //       // Calculate peak flow
  //       if (flowArray.isNotEmpty) {
  //         peakFlow.value =
  //             flowArray.reduce((curr, next) => curr > next ? curr : next);
  //       }
  //       // Update FVC (last volume reading)
  //       if (volumeArray.isNotEmpty) {
  //         fvc.value = volumeArray.last;
  //       }
  //       // Calculate FEV1 (volume at 1 second)
  //       if (timeArray.isNotEmpty && volumeArray.isNotEmpty) {
  //         final oneSecondIndex = timeArray.indexWhere((time) => time >= 1.0);
  //         if (oneSecondIndex != -1) {
  //           fev1.value = volumeArray[oneSecondIndex];
  //         }
  //       }
  //     } catch (e) {
  //       log('Error processing progress update: $e');
  //     }
  //   };
  //   pocSafey.onError = (error) {
  //     handleError(error);
  //   };
  //   pocSafey.onTestFileGenerated = (String filePath) {
  //     lastGeneratedFilePath.value = filePath;
  //     isTestCompleted.value = true;
  //     isTesting.value = false;
  //     stopTimer(); // Stop the timer when test is completed NEW
  //     Get.snackbar(
  //       'Test Completed',
  //       'Results saved successfully',
  //       mainButton: TextButton(
  //         onPressed: () => openTestFile(),
  //         child: const Text('Open File', style: TextStyle(color: Colors.white)),
  //       ),
  //       duration: const Duration(seconds: 5),
  //       backgroundColor: Colors.green,
  //       colorText: Colors.white,
  //     );
  //   };
  //   // pocSafey.onBatteryStatusChanged = (status) {
  //   //   log('Battery status received: $status');
  //   //   batteryStatus.value = status;
  //   // };
  // }
  void setupListeners() {
    pocSafey.onDeviceDiscovered = (device) {
      devices.add(device);
    };

    pocSafey.onProgressUpdate = (progressData) {
      try {
        // log('progress data is $progressData');
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
        log('Error processing progress update: $e');
      }
    };

    pocSafey.onError = (error) {
      log('pocSafey error in setplistenr is $error');
      handleError(error);
    };

    pocSafey.onTestFileGenerated = (String filePath) async {
      lastGeneratedFilePath.value = filePath;

      // Generate our custom text report and PDF report with chart
      try {
        // First generate text report
        final textFilePath = await reportGenerator.generateTextReport(
          firstName: firstName.value != '' ? firstName.value : "John",
          lastName: lastName.value != '' ? lastName.value : "Doe",
          gender: gender.value != '' ? gender.value : "M",
          dateOfBirth:
              dateOfBirth.value != '' ? dateOfBirth.value : "1-01-2001",
          height:
              height.value.toString() != "0" ? height.value.toString() : "180",
          weight:
              weight.value.toString() != '0' ? weight.value.toString() : '80',
          peakFlow: peakFlow.value,
          fvc: fvc.value,
          fev1: fev1.value,
          flowArray: flowArray,
          volumeArray: volumeArray,
          timeArray: timeArray,
        );

        lastGeneratedFilePath.value = textFilePath;
        log('Generated text report at: $textFilePath');

        // Then get the chart image and generate PDF
        // We'll do this after a brief delay to ensure the chart is rendered
        Future.delayed(const Duration(milliseconds: 500), () async {
          final chartImage = await reportGenerator.captureChart();

          if (chartImage != null) {
            final pdfFilePath = await reportGenerator.generatePdfReport(
              firstName: firstName.value != '' ? firstName.value : "John",
              lastName: lastName.value != '' ? lastName.value : "Doe",
              gender: gender.value != '' ? gender.value : "M",
              dateOfBirth:
                  dateOfBirth.value != '' ? dateOfBirth.value : "1-01-2001",
              height: height.value.toString() != "0"
                  ? height.value.toString()
                  : "180",
              weight: weight.value.toString() != '0'
                  ? weight.value.toString()
                  : '80',
              peakFlow: peakFlow.value,
              fvc: fvc.value,
              fev1: fev1.value,
              flowVolumePoints:
                  getFlowVolumePoints().map((p) => p.flow).toList(),
              chartImage: chartImage,
            );

            lastGeneratedPdfPath.value = pdfFilePath;
            log('Generated PDF report at: $pdfFilePath');
          } else {
            log('Failed to capture chart image');
          }
        });
      } catch (e) {
        log('Error generating reports: $e');
        handleError('Report generation error: $e');
      }

      isTestCompleted.value = true;
      isTesting.value = false;
      stopTimer(); // Stop the timer when test is completed

      Get.snackbar(
        'Test Completed',
        'Results saved successfully',
        mainButton: TextButton(
          onPressed: () => showReportOptions(),
          child:
              const Text('View Reports', style: TextStyle(color: Colors.white)),
        ),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    };

    pocSafey.onBatteryStatusChanged = (status) {
      log('Battery status received: $status');
      batteryStatus.value = status;
    };
  }

  void showReportOptions() {
    Get.dialog(
      AlertDialog(
        title: const Text('Test Reports'),
        content: const Text('Which report would you like to open?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              openTextReport();
            },
            child: const Text('Text Report'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openPdfReport();
            },
            child: const Text('PDF Report with Chart'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Open the text report
  void openTextReport() {
    if (lastGeneratedFilePath.value.isNotEmpty) {
      OpenFile.open(lastGeneratedFilePath.value).then((result) {
        log('Text file open result: ${result.message}');
        if (result.type != ResultType.done) {
          handleError('Failed to open text file: ${result.message}');
        }
      });
    } else {
      handleError('No text report available');
    }
  }

  // Open the PDF report
  void openPdfReport() {
    if (lastGeneratedPdfPath.value.isNotEmpty) {
      OpenFile.open(lastGeneratedPdfPath.value).then((result) {
        log('PDF file open result: ${result.message}');
        if (result.type != ResultType.done) {
          handleError('Failed to open PDF file: ${result.message}');
        }
      });
    } else {
      handleError('No PDF report available');
    }
  }

  // For backward compatibility
  void openTestFile() {
    showReportOptions();
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
      // if (!await requestPermissions()) return;
      isLoading.value = true;
      isScanning.value = true;
      devices.clear();

      await pocSafey.scanDevices();
    } catch (e) {
      handleError('Failed to scan devices: $e');
    } finally {
      isLoading.value = false;
      isScanning.value = false;
      // update();
      log('lengh on device in scan is ${devices.length}');
    }
  }

  Future<void> connectDevice() async {
    try {
      if (devices.isNotEmpty) {
        await pocSafey.connectDevice();
        isConnected.value = true;
        pocSafey.onBatteryStatusChanged = (status) {
          batteryStatus.value = status;
        };
        log('Battery status received: ${batteryStatus.value}');
        Get.snackbar(
          'Success',
          'Device connected successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        log('lengh on device in connect is ${devices.length}');
      } else {
        Get.snackbar(
          'User Alert',
          'No device available to connect',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        log('lengh on device in connect is ${devices.length}');
      }
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
      batteryStatus.value = ''; // Clear battery status on disconnect
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
      log('lengh on device in strt trial is ${devices.length}');
    } on TimeoutException {
      handleError('Connection timeout. Please reconnect the device.');
      isTesting.value = false;
      isConnected.value = false;
      log('lengh on device in strt trial is ${devices.length}');
    } catch (e) {
      handleError('Failed to start trial: $e');
      stopTimer();
      isTesting.value = false;
      log('lengh on device in strt trial is ${devices.length}');
    }
  }

  Future<void> stopTrial() async {
    try {
      if (!isTesting.value) {
        return; // No need to stop if not testing
      }

      await pocSafey.stopTrial();
      isTesting.value = false;
      log('lengh on device in stop trial is ${devices.length}');
      stopTimer(); // Stop the timer you started in startTrial
    } catch (e) {
      log('stop trial erro is $e');
      log('lengh on device in stop trial is ${devices.length}');
      handleError('Failed to stop trial: $e');
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

  // void openTestFile() {
  //   if (lastGeneratedFilePath.value.isNotEmpty) {
  //     OpenFile.open(lastGeneratedFilePath.value).then((result) {
  //       log('test result is ${result.message}');
  //       //log('test result is ${result.}');

  //       if (result.type != ResultType.done) {
  //         handleError('Failed to open file: ${result.message}');
  //       }
  //     });
  //   }
  // }

  List<FlowVolumePoint> getFlowVolumePoints() {
    final points = <FlowVolumePoint>[];
    for (var i = 0; i < flowArray.length && i < volumeArray.length; i++) {
      points.add(FlowVolumePoint(volumeArray[i], flowArray[i]));
    }
    return points;
  }

  void handleError(String message) {
    stopTimer();
    stopTrial();
    Get.snackbar(
      'User Alert',
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
