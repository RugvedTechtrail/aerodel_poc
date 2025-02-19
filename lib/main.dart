// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
// import 'package:permission_handler/permission_handler.dart';

// import 'package/poc_safey.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   bool _connected = false;
//   final _pocSafeyPlugin = PocSafey();
//   List<Object> devices = [];

//   String? gender = kDebugMode ? 'male' : null;
//   TextEditingController dob =
//       TextEditingController(text: kDebugMode ? '1990-01-01' : '');
//   TextEditingController fname =
//       TextEditingController(text: kDebugMode ? 'John' : '');
//   TextEditingController lname =
//       TextEditingController(text: kDebugMode ? 'Doe' : '');
//   TextEditingController height =
//       TextEditingController(text: kDebugMode ? '180' : '');
//   TextEditingController weight =
//       TextEditingController(text: kDebugMode ? '80' : '');

//   var maskFormatter = MaskTextInputFormatter(
//       mask: '####-##-##',
//       filter: {"#": RegExp(r'[0-9]')},
//       type: MaskAutoCompletionType.lazy);

//   double currentProgress = 0.0;
//   double currentFlow = 0.0;
//   double currentVolume = 0.0;
//   double currentTime = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();

//     _pocSafeyPlugin.onDeviceDiscovered = (device) {
//       log('device: $device');
//       devices.add(device);
//       setState(() {});
//     };
//     if (kDebugMode) {
//       _pocSafeyPlugin.setFirstName(fname.text);
//       _pocSafeyPlugin.setLastName(lname.text);
//       _pocSafeyPlugin.setGender(gender ?? 'male');
//       _pocSafeyPlugin.setDateOfBirth(dob.text);
//       _pocSafeyPlugin.setHeight(height.text);
//       _pocSafeyPlugin.setWeight(weight.text);
//     }

//     _pocSafeyPlugin.onProgressUpdate = (progressData) {
//       setState(() {
//         currentProgress = progressData['progress'] as double;
//         currentFlow = progressData['flow'] as double;
//         currentVolume = progressData['volume'] as double;
//         currentTime = progressData['time'] as double;
//       });
//     };

//     // _pocSafeyPlugin.onLastConnectedDevice = (deviceId) {
//     //   print('deviceId: $deviceId');
//     // };

//     // _pocSafeyPlugin.onError = (error) {
//     //   print('error: $error');
//     // };
//   }

//   Widget _buildProgressIndicator() {
//     return Column(
//       children: [
//         LinearProgressIndicator(value: currentProgress / 100),
//         Text('Progress: ${currentProgress.toStringAsFixed(2)}%'),
//         Text('Flow: ${currentFlow.toStringAsFixed(2)}'),
//         Text('Volume: ${currentVolume.toStringAsFixed(2)}'),
//         Text('Time: ${currentTime.toStringAsFixed(2)}'),
//       ],
//     );
//   }

//   // Future<void> initPlatformState() async {
//   //   bool? connected;
//   //   try {
//   //     connected = await _pocSafeyPlugin.getConnected();
//   //   } on PlatformException {}

//   //   // If the widget was removed from the tree while the asynchronous platform
//   //   // message was in flight, we want to discard the reply rather than calling
//   //   // setState to update our non-existent appearance.
//   //   if (!mounted) return;

//   //   setState(() {
//   //     _connected = connected ?? false;
//   //   });
//   // }
//   //   void _setupListeners() {
//   //   _pocSafeyPlugin.onDeviceDiscovered = (device) {
//   //     setState(() {
//   //       devices.add(device as Map<String, String>);
//   //       log('in lisntr deivie ar $device');
//   //     });
//   //   };

//   //   _pocSafeyPlugin.onProgressUpdate = (progressData) {
//   //     setState(() {
//   //       currentProgress = progressData['progress'] as double;
//   //       currentFlow = progressData['flow'] as double;
//   //       currentVolume = progressData['volume'] as double;
//   //       currentTime = progressData['time'] as double;
//   //     });
//   //   };
//   // }

//   Future<void> initPlatformState() async {
//     bool? connected;
//     try {
//       connected = await _pocSafeyPlugin.getConnected();
//       log('faf ${_pocSafeyPlugin.onDeviceDiscovered}');
//       _pocSafeyPlugin.onDeviceDiscovered = (device) {
//         log('device in initplatoforn state func: $device');
//         devices.add(device);
//         setState(() {});
//       };
//     } on PlatformException {
//       _showSnackBar("Failed to check connection status.");
//     }
//     if (!mounted) return;
//     setState(() {
//       _connected = connected ?? false;
//     });
//   }

//   void _showSnackBar(String message) {
//     // Ensure ScaffoldMessenger is available
//     // Fluttertoast.showToast(
//     //     msg: "$message",
//     //     toastLength: Toast.LENGTH_SHORT,
//     //     gravity: ToastGravity.CENTER,
//     //     timeInSecForIosWeb: 1,
//     //     backgroundColor: Colors.yellow,
//     //     textColor: Colors.green,
//     //     fontSize: 16.0);
//     Get.snackbar("Aerodel POC", message);
//   }

//   Future<void> _requestPermissions() async {
//     final permissions = [
//       Permission.bluetooth,
//       Permission.bluetoothConnect,
//       Permission.bluetoothScan,
//       Permission.location,
//       Permission.storage,
//       Permission.manageExternalStorage,
//       Permission.manageExternalStorage
//     ];

//     for (final permission in permissions) {
//       final status = await permission.request();
//       if (status.isDenied || status.isPermanentlyDenied) {
//         _showSnackBar("Permission denied: ${permission.toString()}");
//         return;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _buildProgressIndicator(),
//                 TextField(
//                   controller: fname,
//                   decoration: const InputDecoration(
//                     hintText: 'First Name',
//                   ),
//                   onChanged: (value) {
//                     _pocSafeyPlugin.setFirstName(value);
//                   },
//                 ),
//                 TextField(
//                   controller: lname,
//                   decoration: const InputDecoration(
//                     hintText: 'Last Name',
//                   ),
//                   onChanged: (value) {
//                     _pocSafeyPlugin.setLastName(value);
//                   },
//                 ),
//                 DropdownButton(
//                   hint: const Text('Gender'),
//                   value: gender,
//                   items: const [
//                     DropdownMenuItem(value: 'male', child: Text('Male')),
//                     DropdownMenuItem(value: 'female', child: Text('Female'))
//                   ],
//                   onChanged: (value) {
//                     _pocSafeyPlugin.setGender(value.toString());
//                     setState(() {
//                       gender = value.toString();
//                     });
//                   },
//                 ),

//                 TextField(
//                   controller: dob,
//                   inputFormatters: [maskFormatter],
//                   decoration: const InputDecoration(
//                     labelText: 'Date of Birth',
//                     hintText: 'YYYY-MM-DD',
//                   ),
//                   onChanged: (value) {
//                     _pocSafeyPlugin.setDateOfBirth(value);
//                   },
//                 ),
//                 // height
//                 TextField(
//                   controller: height,
//                   decoration: const InputDecoration(
//                     labelText: 'Height',
//                     hintText: 'Enter your height in cm',
//                   ),
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) {
//                     _pocSafeyPlugin.setHeight(value);
//                   },
//                 ),
//                 // weight
//                 TextField(
//                   controller: weight,
//                   decoration: const InputDecoration(
//                     labelText: 'Weight',
//                     hintText: 'Enter your weight in kg',
//                   ),
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) {
//                     _pocSafeyPlugin.setWeight(value);
//                   },
//                 ),
//                 Text('is Connected: $_connected'),
//                 Text('devices: $devices'),
//                 ElevatedButton(
//                   child: const Text('Scan Devices'),
//                   onPressed: () async {
//                     devices.clear();
//                     _requestPermissions().whenComplete(
//                       () {},
//                     );
//                     await _pocSafeyPlugin.scanDevices();
//                     _pocSafeyPlugin.onDeviceDiscovered = (device) {
//                       log('device: $device');
//                       devices.add(device);
//                       setState(() {});
//                     };
//                   },
//                 ),
//                 Row(
//                   children: [
//                     ElevatedButton(
//                       child: const Text('Connect Device'),
//                       onPressed: () async {
//                         _pocSafeyPlugin.onDeviceDiscovered = (device) {
//                           log('device: $device');
//                           devices.add(device);
//                         };
//                         await _pocSafeyPlugin.connectDevice();
//                       },
//                     ),
//                     ElevatedButton(
//                       child: const Text('Disconnect Device'),
//                       onPressed: () async {
//                         log('taped on dissconnect');
//                         _pocSafeyPlugin.onProgressUpdate = (progress) {
//                           log('progress after trail in trila buttonn is : $progress');
//                         };
//                         await _pocSafeyPlugin.disconnectDevice();
//                       },
//                     ),
//                   ],
//                 ),
//                 ElevatedButton(
//                   child: const Text('Start Trial'),
//                   onPressed: () async {
//                     _pocSafeyPlugin.onDeviceDiscovered = (device) {
//                       log('device: $device');
//                     };
//                     await _pocSafeyPlugin.startTrial();
//                     _pocSafeyPlugin.onProgressUpdate = (progress) {
//                       log('progress after trail in trila buttonn is : $progress');
//                     };
//                   },
//                 ),
//                 ElevatedButton(
//                   child: const Text('check'),
//                   onPressed: () async {
//                     // _pocSafeyPlugin.onDeviceDiscovered = (device) {
//                     //   log('device: $device');
//                     // };

//                     _pocSafeyPlugin.onProgressUpdate = (progress) {
//                       log('progress after trail in trila buttonn is : $progress');
//                     };
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // import 'dart:async';
// // import 'dart:developer';
// // import 'package:aerodel_poc/package/poc_safey.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:get/get.dart';

// // import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
// // import 'package:permission_handler/permission_handler.dart';

// // void main() {
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatefulWidget {
// //   const MyApp({super.key});

// //   @override
// //   State<MyApp> createState() => _MyAppState();
// // }

// // class _MyAppState extends State<MyApp> {
// //   bool _connected = false;
// //   final _pocSafeyPlugin = PocSafey();
// //   List<Map<String, String>> devices = [];
// //   String? gender;
// //   TextEditingController dob = TextEditingController();
// //   TextEditingController fname = TextEditingController();
// //   TextEditingController lname = TextEditingController();
// //   TextEditingController height = TextEditingController();
// //   TextEditingController weight = TextEditingController();

// //   var maskFormatter = MaskTextInputFormatter(
// //       mask: '####-##-##',
// //       filter: {"#": RegExp(r'[0-9]')},
// //       type: MaskAutoCompletionType.lazy);

// //   double currentProgress = 0.0;
// //   double currentFlow = 0.0;
// //   double currentVolume = 0.0;
// //   double currentTime = 0.0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     initPlatformState();
// //     _setupListeners();
// //   }

// //   void _setupListeners() {
// //     _pocSafeyPlugin.onDeviceDiscovered = (device) {
// //       setState(() {
// //         devices.add(device as Map<String, String>);
// //         log('in lisntr deivie ar $device');
// //       });
// //     };

// //     _pocSafeyPlugin.onProgressUpdate = (progressData) {
// //       setState(() {
// //         currentProgress = progressData['progress'] as double;
// //         currentFlow = progressData['flow'] as double;
// //         currentVolume = progressData['volume'] as double;
// //         currentTime = progressData['time'] as double;
// //       });
// //     };
// //   }

// //   Future<void> initPlatformState() async {
// //     bool? connected;
// //     try {
// //       connected = await _pocSafeyPlugin.getConnected();
// //     } on PlatformException {
// //       _showSnackBar("Failed to check connection status.");
// //     }
// //     if (!mounted) return;
// //     setState(() {
// //       _connected = connected ?? false;
// //     });
// //   }

// //   void _showSnackBar(String message) {
// //     // Ensure ScaffoldMessenger is available
// //     // Fluttertoast.showToast(
// //     //     msg: "$message",
// //     //     toastLength: Toast.LENGTH_SHORT,
// //     //     gravity: ToastGravity.CENTER,
// //     //     timeInSecForIosWeb: 1,
// //     //     backgroundColor: Colors.yellow,
// //     //     textColor: Colors.green,
// //     //     fontSize: 16.0);
// //     Get.snackbar("Aerodel POC", message);
// //   }

// //   Widget _buildProgressIndicator() {
// //     return Column(
// //       children: [
// //         LinearProgressIndicator(value: currentProgress / 100),
// //         Text('Progress: ${currentProgress.toStringAsFixed(2)}%'),
// //         Text('Flow: ${currentFlow.toStringAsFixed(2)}'),
// //         Text('Volume: ${currentVolume.toStringAsFixed(2)}'),
// //         Text('Time: ${currentTime.toStringAsFixed(2)}'),
// //       ],
// //     );
// //   }

// //   Future<void> _requestPermissions() async {
// //     final permissions = [
// //       Permission.bluetooth,
// //       Permission.bluetoothConnect,
// //       Permission.bluetoothScan,
// //       Permission.location,
// //       Permission.storage,
// //       Permission.manageExternalStorage,
// //     ];

// //     for (final permission in permissions) {
// //       final status = await permission.request();
// //       if (status.isDenied || status.isPermanentlyDenied) {
// //         _showSnackBar("Permission denied: ${permission.toString()}");
// //         return;
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GetMaterialApp(
// //       home: Scaffold(
// //         appBar: AppBar(
// //           title: const Text('Safey Plugin Example'),
// //         ),
// //         body: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: SingleChildScrollView(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 _buildProgressIndicator(),
// //                 const SizedBox(height: 20),
// //                 TextField(
// //                   controller: fname,
// //                   decoration: const InputDecoration(
// //                     labelText: 'First Name',
// //                     hintText: 'Enter your first name',
// //                   ),
// //                   onChanged: (value) {
// //                     _pocSafeyPlugin.setFirstName(value);
// //                   },
// //                 ),
// //                 const SizedBox(height: 10),
// //                 TextField(
// //                   controller: lname,
// //                   decoration: const InputDecoration(
// //                     labelText: 'Last Name',
// //                     hintText: 'Enter your last name',
// //                   ),
// //                   onChanged: (value) {
// //                     _pocSafeyPlugin.setLastName(value);
// //                   },
// //                 ),
// //                 const SizedBox(height: 10),
// //                 DropdownButtonFormField<String>(
// //                   hint: const Text('Select Gender'),
// //                   value: gender,
// //                   items: const [
// //                     DropdownMenuItem(value: 'male', child: Text('Male')),
// //                     DropdownMenuItem(value: 'female', child: Text('Female')),
// //                   ],
// //                   onChanged: (value) {
// //                     _pocSafeyPlugin.setGender(value ?? 'M');
// //                     setState(() {
// //                       gender = value;
// //                     });
// //                   },
// //                 ),
// //                 const SizedBox(height: 10),
// //                 TextField(
// //                   controller: dob,
// //                   inputFormatters: [maskFormatter],
// //                   decoration: const InputDecoration(
// //                     labelText: 'Date of Birth',
// //                     hintText: 'YYYY-MM-DD',
// //                   ),
// //                   onChanged: (value) {
// //                     _pocSafeyPlugin.setDateOfBirth(value);
// //                   },
// //                 ),
// //                 const SizedBox(height: 10),
// //                 TextField(
// //                   controller: height,
// //                   decoration: const InputDecoration(
// //                     labelText: 'Height',
// //                     hintText: 'Enter your height in cm',
// //                   ),
// //                   keyboardType: TextInputType.number,
// //                   onChanged: (value) {
// //                     _pocSafeyPlugin.setHeight(value);
// //                   },
// //                 ),
// //                 const SizedBox(height: 10),
// //                 TextField(
// //                   controller: weight,
// //                   decoration: const InputDecoration(
// //                     labelText: 'Weight',
// //                     hintText: 'Enter your weight in kg',
// //                   ),
// //                   keyboardType: TextInputType.number,
// //                   onChanged: (value) {
// //                     _pocSafeyPlugin.setWeight(value);
// //                   },
// //                 ),
// //                 const SizedBox(height: 20),
// //                 Text('Connected: $_connected'),
// //                 const SizedBox(height: 10),
// //                 Text('Devices: ${devices.map((d) => d['name']).join(", ")}'),
// //                 const SizedBox(height: 20),
// //                 ElevatedButton(
// //                   onPressed: () async {
// //                     await _requestPermissions();
// //                     devices.clear();
// //                     log('devices are $devices');
// //                     await _pocSafeyPlugin.scanDevices();

// //                     //  _showSnackBar("Scanning devices...");
// //                   },
// //                   child: const Text('Scan Devices'),
// //                 ),
// //                 const SizedBox(height: 10),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Expanded(
// //                       child: ElevatedButton(
// //                         onPressed: () async {
// //                           // if (devices.isEmpty) {
// //                           //   _showSnackBar("No devices available to connect.");
// //                           //   return;
// //                           // }

// //                           _showSnackBar("Connecting to device...");
// //                           await _pocSafeyPlugin.connectDevice();
// //                           log('devices are $devices');
// //                           _setupListeners();
// //                           log('dfasfafaf');
// //                         },
// //                         child: const Text('Connect Device'),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 10),
// //                     Expanded(
// //                       child: ElevatedButton(
// //                         onPressed: () async {
// //                           await _pocSafeyPlugin.disconnectDevice();
// //                           _showSnackBar("Disconnected from device.");
// //                         },
// //                         child: const Text('Disconnect Device'),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 10),
// //                 ElevatedButton(
// //                   onPressed: () async {
// //                     if (!_connected) {
// //                       _showSnackBar("Please connect to a device first.");
// //                       return;
// //                     }
// //                     log('start tirila');
// //                     await _pocSafeyPlugin.startTrial();
// //                     _showSnackBar("Starting trial...");
// //                   },
// //                   child: const Text('Start Trial'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

import 'package:aerodel_poc/controllers/spirometer_controller.dart';
import 'package:aerodel_poc/theme/apptheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(SpirometryController()); // Initialize controller
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Spirometry App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}









//safeywaper.kt

// package com.example.aerodel_poc

// import android.bluetooth.BluetoothDevice
// import android.content.Context
// import android.content.pm.PackageManager
// import android.os.Environment
// import android.widget.Toast
// import com.safey.safeysdk.callbacks.*
// import com.safey.safeysdk.classes.SafeyLungManager
// import com.safey.safeysdk.model.SafeyPerson
// import com.safey.safeysdk.model.SafeySpirometerDevice
// import com.safey.safeysdk.model.TestResultsModel
// import com.safey.safeysdk.utils.Constants
// import io.flutter.plugin.common.MethodCall
// import io.flutter.plugin.common.MethodChannel
// import io.flutter.plugin.common.MethodChannel.MethodCallHandler
// import java.io.File
// import java.util.Date
// import java.util.Timer

// class SafeyManagerWrapper(private val context: Context) :
//     SafeyScannerCallback,
//     SafeyErrorCallback,
//     SafeyDeviceCallback,
//     SafeyConnectionCallback,
//     SafeyTrialCallback,
//     SafeyTestTypeCallback,
//     SafeyTestCallback {

//     private lateinit var safeyLungManager: SafeyLungManager
//     private val discoveredDevices = mutableListOf<SafeySpirometerDevice>()
//     internal lateinit var channel: MethodChannel
//     private lateinit var testResultsModel: TestResultsModel

//     private var firstName: String = "John"
//     private var lastName: String = "Doe"
//     private var gender: Constants.Gender = Constants.Gender.Male
//     private var dateOfBirth: Date = Date(1993, 1, 1)
//     private var heightInCentimeters: Int = 180
//     private var weightInKg: Double = 90.0

//     init {
//         initSafeyLungManager()
//     }

//     fun initSafeyLungManager() {
//         try {
//             println("Initializing SafeyLungManager")
//             println("First Name: $firstName")
//             println("Last Name: $lastName")
//             println("Gender: $gender")
//             println("Date of Birth: $dateOfBirth")
//             println("Height: $heightInCentimeters")
//             println("Weight: $weightInKg")

//             val person = SafeyPerson(
//                 firstName,
//                 lastName,
//                 gender,
//                 Constants.PredictionLibraries.CHHABRA,
//                 Constants.Ethnicity.Indian,
//                 dateOfBirth = dateOfBirth,
//                 heightInCentimeters = heightInCentimeters,
//                 weightInKg = weightInKg,
//             )
//             safeyLungManager = SafeyLungManager.init(person, context)!!
//             registerCallbacks()
//         } catch (e: Exception) {
//             println("Error initializing SafeyLungManager: $e")
//             channel.invokeMethod("onError", "Failed to initialize: ${e.message}")
//         }
//     }

//     private fun registerCallbacks() {
//         try {
//             println("Registering callbacks")
//             safeyLungManager.apply {
//                 registerErrorCallback(this@SafeyManagerWrapper)
//                 registerDeviceCallback(this@SafeyManagerWrapper)
//                 registerConnectionCallback(this@SafeyManagerWrapper)
//                 registerTrialCallback(this@SafeyManagerWrapper)
//                 registerTestTypeCallback(this@SafeyManagerWrapper)
//                 registerScannerCallback(this@SafeyManagerWrapper)
//                 registerTestCallback(this@SafeyManagerWrapper)
//             }
//         } catch (e: Exception) {
//             println("Error registering callbacks: $e")
//             channel.invokeMethod("onError", "Failed to register callbacks: ${e.message}")
//         }
//     }

//     fun startTest(safeyPerson: SafeyPerson) {
//         try {
//             safeyLungManager.startTest(safeyPerson)
//         } catch (e: Exception) {
//             println("Error starting test: $e")
//             channel.invokeMethod("onError", "Failed to start test: ${e.message}")
//         }
//     }

//     fun stopTest() {
//         try {
//             safeyLungManager.stopTrial()
//         } catch (e: Exception) {
//             println("Error stopping test: $e")
//             channel.invokeMethod("onError", "Failed to stop test: ${e.message}")
//         }
//     }

//     override fun getConnected(isConnected: Boolean) {
//         try {
//             channel.invokeMethod("onConnectionStatusChanged", isConnected)
//         } catch (e: Exception) {
//             println("Error sending connection status: $e")
//         }
//     }

//     override fun enableTest() {
//         println("Test enabled")
//     }

//     override fun getBatteryStatus(batteryStatus: String) {
//         println("Battery status: $batteryStatus")
//     }

//     override fun error(safeyDeviceManagerInfoState: SafeyDeviceManagerInfoState, message: String) {
//         println("Error: $safeyDeviceManagerInfoState, $message")
//         channel.invokeMethod("onError", "Device error: $message")
//     }

//     override fun getBluetoothDevice(device: SafeySpirometerDevice) {
//         try {
//             println("Discovered device: $device")
//             discoveredDevices.add(device)
//             val deviceMap = mapOf(
//                 "name" to device.deviceName,
//                 "address" to device.bluetoothDevice.address
//             )
//             channel.invokeMethod("onDeviceDiscovered", deviceMap)
//         } catch (e: Exception) {
//             println("Error handling discovered device: $e")
//             channel.invokeMethod("onError", "Failed to process discovered device: ${e.message}")
//         }
//     }

//     override fun lastConnectedDeviceFound(device: BluetoothDevice) {
//         try {
//             println("Last connected device found: $device")
//             val deviceMap = mapOf(
//                 "name" to device.name,
//                 "address" to device.address
//             )
//             channel.invokeMethod("onLastConnectedDeviceFound", deviceMap)
//         } catch (e: Exception) {
//             println("Error handling last connected device: $e")
//         }
//     }

//     override fun getTestType(
//         device: SafeySpirometerDevice,
//         availableTestType: Array<Constants.TestType>
//     ) {
//         try {
//             println("Test type: $availableTestType")
//             val testTypes = availableTestType.map { it.name }
//             channel.invokeMethod("onTestTypeDiscovered", testTypes)
//         } catch (e: Exception) {
//             println("Error handling test type: $e")
//         }
//     }

//     override fun selectTestType(): Constants.TestType {
//         return Constants.TestType.FEVC
//     }

//     override fun enableTrial() {
//         try {
//             safeyLungManager.startTrial()
//             Toast.makeText(context, "Trial started", Toast.LENGTH_SHORT).show()
//         } catch (e: Exception) {
//             println("Error enabling trial: $e")
//             channel.invokeMethod("onError", "Failed to start trial: ${e.message}")
//         }
//     }

//     fun startTestSession() {
//         try {
//             Toast.makeText(context, "Trial session started", Toast.LENGTH_SHORT).show()
//             safeyLungManager.startTestSession(null)
//         } catch (e: Exception) {
//             println("Error starting test session: $e")
//             channel.invokeMethod("onError", "Failed to start test session: ${e.message}")
//         }
//     }

//     fun dispose() {
//         try {
//             safeyLungManager.unregisterCallbacks()
//         } catch (e: Exception) {
//             println("Error disposing: $e")
//         }
//     }

//     fun isConnected(): Boolean {
//         return try {
//             safeyLungManager.isConnected()
//         } catch (e: Exception) {
//             println("Error checking connection: $e")
//             false
//         }
//     }

//     fun scanDevices() {
//         try {
//             initSafeyLungManager()
//             discoveredDevices.clear()
//             safeyLungManager.scanDevice()
//         } catch (e: Exception) {
//             println("Error scanning devices: $e")
//             channel.invokeMethod("onError", "Failed to scan devices: ${e.message}")
//         }
//     }

//     fun connectToDevice() {
//         try {
//             val device = discoveredDevices.firstOrNull()
//             device?.let {
//                 safeyLungManager.connectDevice(it)
//             } ?: run {
//                 channel.invokeMethod("onError", "No device found to connect")
//             }
//         } catch (e: Exception) {
//             println("Error connecting to device: $e")
//             channel.invokeMethod("onError", "Failed to connect: ${e.message}")
//         }
//     }

//     override fun getTestResult(testResult: TestResultsModel, trialCount: Int) {
//         try {
//             println("Test result: $testResult, trial count: $trialCount")
//             testResultsModel = testResult
//         } catch (e: Exception) {
//             println("Error handling test result: $e")
//         }
//     }

//     override fun getTestResults(testResult: TestResultsModel) {
//         try {
//             println("Test results: $testResult")
//             testResultsModel = testResult

//             val externalDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
//             val currentYear = Date().year + 1900
//             val birthYear = dateOfBirth.year + 1900
//             val age = currentYear - birthYear

//             val fileName = "${firstName}_${lastName}_${age}_${gender.name}_${heightInCentimeters}_${weightInKg}.txt"
//             val filePath = externalDir.absolutePath + "/" + fileName
//             val file = File(filePath)

//             try {
//                 val fileWriter = file.bufferedWriter()
//                 fileWriter.use {
//                     it.write("Test results: $testResult")
//                 }
//                 println("File written to: $filePath")
//                 Toast.makeText(context, "File created at $filePath", Toast.LENGTH_SHORT).show()
//                 channel.invokeMethod("onTestFileGenerated", filePath)
//             } catch (e: Exception) {
//                 println("Error writing to file: $e")
//                 channel.invokeMethod("onError", "Failed to save test results: ${e.message}")
//             }
//         } catch (e: Exception) {
//             println("Error handling test results: $e")
//             channel.invokeMethod("onError", "Failed to process test results: ${e.message}")
//         }
//     }

//     override fun invalidManeuver(trialCount: Int) {
//         println("Invalid maneuver")
//         channel.invokeMethod("onError", "Invalid maneuver detected")
//     }

//     override fun onProgressChange(
//         progress: Double,
//         flow: ArrayList<Double>,
//         volume: ArrayList<Double>,
//         time: ArrayList<Double>
//     ) {
//         try {
//             val latestFlow = flow.lastOrNull() ?: 0.0
//             val latestVolume = volume.lastOrNull() ?: 0.0
//             val latestTime = time.lastOrNull() ?: 0.0

//             val progressData = mapOf(
//                 "progress" to progress,
//                 "flow" to latestFlow,
//                 "volume" to latestVolume,
//                 "time" to latestTime,
//                 "flowArray" to ArrayList(flow),
//                 "volumeArray" to ArrayList(volume),
//                 "timeArray" to ArrayList(time)
//             )
            
//             channel.invokeMethod("onProgressUpdate", progressData)
//         } catch (e: Exception) {
//             println("Error sending progress update: $e")
//         }
//     }

//     override fun testCompleted() {
//         try {
//             println("Test completed")
//             Toast.makeText(context, "Test completed", Toast.LENGTH_SHORT).show()
//             channel.invokeMethod("onTestCompleted", null)
//         } catch (e: Exception) {
//             println("Error handling test completion: $e")
//         }
//     }

//     fun disconnectDevice() {
//         try {
//             safeyLungManager.disconnect()
//         } catch (e: Exception) {
//             println("Error disconnecting device: $e")
//             channel.invokeMethod("onError", "Failed to disconnect: ${e.message}")
//         }
//     }

//     fun setFirstName(firstName: String?) {
//         try {
//             this.firstName = firstName ?: this.firstName
//             println("First Name: $firstName")
//             Toast.makeText(context, "First name set: $firstName", Toast.LENGTH_SHORT).show()
//         } catch (e: Exception) {
//             println("Error setting first name: $e")
//             channel.invokeMethod("onError", "Failed to set first name: ${e.message}")
//         }
//     }

//     fun setLastName(lastName: String?) {
//         try {
//             this.lastName = lastName ?: this.lastName
//             println("Last Name: $lastName")
//             Toast.makeText(context, "Last name set: $lastName", Toast.LENGTH_SHORT).show()
//         } catch (e: Exception) {
//             println("Error setting last name: $e")
//             channel.invokeMethod("onError", "Failed to set last name: ${e.message}")
//         }
//     }

//     fun setGender(gender: String?) {
//         try {
//             this.gender = when (gender?.toLowerCase()) {
//                 "male" -> Constants.Gender.Male
//                 "female" -> Constants.Gender.Female
//                 else -> this.gender
//             }
//             println("Gender: $gender")
//             Toast.makeText(context, "Gender set: $gender", Toast.LENGTH_SHORT).show()
//         } catch (e: Exception) {
//             println("Error setting gender: $e")
//             channel.invokeMethod("onError", "Failed to set gender: ${e.message}")
//         }
//     }

//     fun setDateOfBirth(year: Int?, month: Int?, day: Int?) {
//         try {
//             if (year != null && month != null && day != null) {
//                 this.dateOfBirth = Date(year - 1900, month - 1, day)
//             }
//             println("Date of Birth: $year-$month-$day")
//             Toast.makeText(context, "Date of birth set: $year-$month-$day", Toast.LENGTH_SHORT).show()
//         } catch (e: Exception) {
//             println("Error setting date of birth: $e")
//             channel.invokeMethod("onError", "Failed to set date of birth: ${e.message}")
//         }
//     }

//     fun setHeight(height: Int?) {
//         try {
//             this.heightInCentimeters = height ?: this.heightInCentimeters
//             println("Height: $height cm")
//             Toast.makeText(context, "Height set: $height", Toast.LENGTH_SHORT).show()
//         } catch (e: Exception) {
//             println("Error setting height: $e")
//             channel.invokeMethod("onError", "Failed to set height: ${e.message}")
//         }
//     }

//     fun setWeight(weight: Int?) {
//         try {
//             this.weightInKg = weight?.toDouble() ?: this.weightInKg
//             println("Weight: $weight kg")
//             Toast.makeText(context, "Weight set: $weight", Toast.LENGTH_SHORT).show()
//         } catch (e: Exception) {
//             println("Error setting weight: $e")
//             channel.invokeMethod("onError", "Failed to set weight: ${e.message}")
//         }
//     }
// }