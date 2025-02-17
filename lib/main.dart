import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package/poc_safey.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _connected = false;
  final _pocSafeyPlugin = PocSafey();
  List<Object> devices = [];

  String? gender = kDebugMode ? 'male' : null;
  TextEditingController dob =
      TextEditingController(text: kDebugMode ? '1990-01-01' : '');
  TextEditingController fname =
      TextEditingController(text: kDebugMode ? 'John' : '');
  TextEditingController lname =
      TextEditingController(text: kDebugMode ? 'Doe' : '');
  TextEditingController height =
      TextEditingController(text: kDebugMode ? '180' : '');
  TextEditingController weight =
      TextEditingController(text: kDebugMode ? '80' : '');

  var maskFormatter = MaskTextInputFormatter(
      mask: '####-##-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  double currentProgress = 0.0;
  double currentFlow = 0.0;
  double currentVolume = 0.0;
  double currentTime = 0.0;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    _pocSafeyPlugin.onDeviceDiscovered = (device) {
      log('device: $device');
      devices.add(device);
      setState(() {});
    };
    if (kDebugMode) {
      _pocSafeyPlugin.setFirstName(fname.text);
      _pocSafeyPlugin.setLastName(lname.text);
      _pocSafeyPlugin.setGender(gender ?? 'male');
      _pocSafeyPlugin.setDateOfBirth(dob.text);
      _pocSafeyPlugin.setHeight(height.text);
      _pocSafeyPlugin.setWeight(weight.text);
    }

    _pocSafeyPlugin.onProgressUpdate = (progressData) {
      setState(() {
        currentProgress = progressData['progress'] as double;
        currentFlow = progressData['flow'] as double;
        currentVolume = progressData['volume'] as double;
        currentTime = progressData['time'] as double;
      });
    };

    // _pocSafeyPlugin.onLastConnectedDevice = (deviceId) {
    //   print('deviceId: $deviceId');
    // };

    // _pocSafeyPlugin.onError = (error) {
    //   print('error: $error');
    // };
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        LinearProgressIndicator(value: currentProgress / 100),
        Text('Progress: ${currentProgress.toStringAsFixed(2)}%'),
        Text('Flow: ${currentFlow.toStringAsFixed(2)}'),
        Text('Volume: ${currentVolume.toStringAsFixed(2)}'),
        Text('Time: ${currentTime.toStringAsFixed(2)}'),
      ],
    );
  }

  // Future<void> initPlatformState() async {
  //   bool? connected;
  //   try {
  //     connected = await _pocSafeyPlugin.getConnected();
  //   } on PlatformException {}

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _connected = connected ?? false;
  //   });
  // }
  //   void _setupListeners() {
  //   _pocSafeyPlugin.onDeviceDiscovered = (device) {
  //     setState(() {
  //       devices.add(device as Map<String, String>);
  //       log('in lisntr deivie ar $device');
  //     });
  //   };

  //   _pocSafeyPlugin.onProgressUpdate = (progressData) {
  //     setState(() {
  //       currentProgress = progressData['progress'] as double;
  //       currentFlow = progressData['flow'] as double;
  //       currentVolume = progressData['volume'] as double;
  //       currentTime = progressData['time'] as double;
  //     });
  //   };
  // }

  Future<void> initPlatformState() async {
    bool? connected;
    try {
      connected = await _pocSafeyPlugin.getConnected();
      log('faf ${_pocSafeyPlugin.onDeviceDiscovered}');
      _pocSafeyPlugin.onDeviceDiscovered = (device) {
        log('device in initplatoforn state func: $device');
        devices.add(device);
        setState(() {});
      };
    } on PlatformException {
      _showSnackBar("Failed to check connection status.");
    }
    if (!mounted) return;
    setState(() {
      _connected = connected ?? false;
    });
  }

  void _showSnackBar(String message) {
    // Ensure ScaffoldMessenger is available
    // Fluttertoast.showToast(
    //     msg: "$message",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.yellow,
    //     textColor: Colors.green,
    //     fontSize: 16.0);
    Get.snackbar("Aerodel POC", message);
  }

  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.manageExternalStorage
    ];

    for (final permission in permissions) {
      final status = await permission.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        _showSnackBar("Permission denied: ${permission.toString()}");
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProgressIndicator(),
                TextField(
                  controller: fname,
                  decoration: const InputDecoration(
                    hintText: 'First Name',
                  ),
                  onChanged: (value) {
                    _pocSafeyPlugin.setFirstName(value);
                  },
                ),
                TextField(
                  controller: lname,
                  decoration: const InputDecoration(
                    hintText: 'Last Name',
                  ),
                  onChanged: (value) {
                    _pocSafeyPlugin.setLastName(value);
                  },
                ),
                DropdownButton(
                  hint: const Text('Gender'),
                  value: gender,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female'))
                  ],
                  onChanged: (value) {
                    _pocSafeyPlugin.setGender(value.toString());
                    setState(() {
                      gender = value.toString();
                    });
                  },
                ),

                TextField(
                  controller: dob,
                  inputFormatters: [maskFormatter],
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'YYYY-MM-DD',
                  ),
                  onChanged: (value) {
                    _pocSafeyPlugin.setDateOfBirth(value);
                  },
                ),
                // height
                TextField(
                  controller: height,
                  decoration: const InputDecoration(
                    labelText: 'Height',
                    hintText: 'Enter your height in cm',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _pocSafeyPlugin.setHeight(value);
                  },
                ),
                // weight
                TextField(
                  controller: weight,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    hintText: 'Enter your weight in kg',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _pocSafeyPlugin.setWeight(value);
                  },
                ),
                Text('is Connected: $_connected'),
                Text('devices: $devices'),
                ElevatedButton(
                  child: const Text('Scan Devices'),
                  onPressed: () async {
                    devices.clear();
                    _requestPermissions().whenComplete(
                      () {},
                    );
                    await _pocSafeyPlugin.scanDevices();
                    _pocSafeyPlugin.onDeviceDiscovered = (device) {
                      log('device: $device');
                      devices.add(device);
                      setState(() {});
                    };
                  },
                ),
                Row(
                  children: [
                    ElevatedButton(
                      child: const Text('Connect Device'),
                      onPressed: () async {
                        _pocSafeyPlugin.onDeviceDiscovered = (device) {
                          log('device: $device');
                          devices.add(device);
                        };
                        await _pocSafeyPlugin.connectDevice();
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Disconnect Device'),
                      onPressed: () async {
                        log('taped on dissconnect');
                        _pocSafeyPlugin.onProgressUpdate = (progress) {
                          log('progress after trail in trila buttonn is : $progress');
                        };
                        await _pocSafeyPlugin.disconnectDevice();
                      },
                    ),
                  ],
                ),
                ElevatedButton(
                  child: const Text('Start Trial'),
                  onPressed: () async {
                    _pocSafeyPlugin.onDeviceDiscovered = (device) {
                      log('device: $device');
                    };
                    await _pocSafeyPlugin.startTrial();
                    _pocSafeyPlugin.onProgressUpdate = (progress) {
                      log('progress after trail in trila buttonn is : $progress');
                    };
                  },
                ),
                ElevatedButton(
                  child: const Text('check'),
                  onPressed: () async {
                    // _pocSafeyPlugin.onDeviceDiscovered = (device) {
                    //   log('device: $device');
                    // };

                    _pocSafeyPlugin.onProgressUpdate = (progress) {
                      log('progress after trail in trila buttonn is : $progress');
                    };
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'dart:developer';
// import 'package:aerodel_poc/package/poc_safey.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
// import 'package:permission_handler/permission_handler.dart';

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
//   List<Map<String, String>> devices = [];
//   String? gender;
//   TextEditingController dob = TextEditingController();
//   TextEditingController fname = TextEditingController();
//   TextEditingController lname = TextEditingController();
//   TextEditingController height = TextEditingController();
//   TextEditingController weight = TextEditingController();

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
//     _setupListeners();
//   }

//   void _setupListeners() {
//     _pocSafeyPlugin.onDeviceDiscovered = (device) {
//       setState(() {
//         devices.add(device as Map<String, String>);
//         log('in lisntr deivie ar $device');
//       });
//     };

//     _pocSafeyPlugin.onProgressUpdate = (progressData) {
//       setState(() {
//         currentProgress = progressData['progress'] as double;
//         currentFlow = progressData['flow'] as double;
//         currentVolume = progressData['volume'] as double;
//         currentTime = progressData['time'] as double;
//       });
//     };
//   }

//   Future<void> initPlatformState() async {
//     bool? connected;
//     try {
//       connected = await _pocSafeyPlugin.getConnected();
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

//   Future<void> _requestPermissions() async {
//     final permissions = [
//       Permission.bluetooth,
//       Permission.bluetoothConnect,
//       Permission.bluetoothScan,
//       Permission.location,
//       Permission.storage,
//       Permission.manageExternalStorage,
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
//     return GetMaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Safey Plugin Example'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildProgressIndicator(),
//                 const SizedBox(height: 20),
//                 TextField(
//                   controller: fname,
//                   decoration: const InputDecoration(
//                     labelText: 'First Name',
//                     hintText: 'Enter your first name',
//                   ),
//                   onChanged: (value) {
//                     _pocSafeyPlugin.setFirstName(value);
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: lname,
//                   decoration: const InputDecoration(
//                     labelText: 'Last Name',
//                     hintText: 'Enter your last name',
//                   ),
//                   onChanged: (value) {
//                     _pocSafeyPlugin.setLastName(value);
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 DropdownButtonFormField<String>(
//                   hint: const Text('Select Gender'),
//                   value: gender,
//                   items: const [
//                     DropdownMenuItem(value: 'male', child: Text('Male')),
//                     DropdownMenuItem(value: 'female', child: Text('Female')),
//                   ],
//                   onChanged: (value) {
//                     _pocSafeyPlugin.setGender(value ?? 'M');
//                     setState(() {
//                       gender = value;
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 10),
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
//                 const SizedBox(height: 10),
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
//                 const SizedBox(height: 10),
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
//                 const SizedBox(height: 20),
//                 Text('Connected: $_connected'),
//                 const SizedBox(height: 10),
//                 Text('Devices: ${devices.map((d) => d['name']).join(", ")}'),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () async {
//                     await _requestPermissions();
//                     devices.clear();
//                     log('devices are $devices');
//                     await _pocSafeyPlugin.scanDevices();

//                     //  _showSnackBar("Scanning devices...");
//                   },
//                   child: const Text('Scan Devices'),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           // if (devices.isEmpty) {
//                           //   _showSnackBar("No devices available to connect.");
//                           //   return;
//                           // }

//                           _showSnackBar("Connecting to device...");
//                           await _pocSafeyPlugin.connectDevice();
//                           log('devices are $devices');
//                           _setupListeners();
//                           log('dfasfafaf');
//                         },
//                         child: const Text('Connect Device'),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           await _pocSafeyPlugin.disconnectDevice();
//                           _showSnackBar("Disconnected from device.");
//                         },
//                         child: const Text('Disconnect Device'),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (!_connected) {
//                       _showSnackBar("Please connect to a device first.");
//                       return;
//                     }
//                     log('start tirila');
//                     await _pocSafeyPlugin.startTrial();
//                     _showSnackBar("Starting trial...");
//                   },
//                   child: const Text('Start Trial'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }











// package com.example.aerodel_poc

// import io.flutter.embedding.android.FlutterActivity
// import io.flutter.embedding.engine.FlutterEngine
// import io.flutter.plugin.common.MethodChannel

// class MainActivity: FlutterActivity() {
//     private lateinit var safeyManagerWrapper: SafeyManagerWrapper


//     override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//         super.configureFlutterEngine(flutterEngine)
//         safeyManagerWrapper = SafeyManagerWrapper(context)
//         val backgroundChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "background_poc_safey")
//         safeyManagerWrapper.channel = backgroundChannel

//         MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "poc_safey").setMethodCallHandler { call, result ->
//             // TODO
//             when (call.method) {
//                 "getConnected" -> {
//                     result.success(true)
//                 }
//                 "scanDevices" -> {
//                     safeyManagerWrapper.scanDevices()
//                 }
//                 "connectDevice" -> {
// //            val device = call.argument<BluetoothDevice>("device")
//                     safeyManagerWrapper.connectToDevice()
//                 }
//                 "disconnectDevice" -> {
//                     safeyManagerWrapper.disconnectDevice()
//                 }
//                 "startTrial" -> {
//                     safeyManagerWrapper.startTestSession()
// //            safeyManagerWrapper.enableTrial()
//                 }
//                  "setFirstName" -> {
//             val firstName = call.argument<String>("firstName")
//             safeyManagerWrapper.setFirstName(firstName)
//         }
//         "setLastName" -> {
//             val lastName = call.argument<String>("lastName")
//             safeyManagerWrapper.setLastName(lastName)
//         }
//         "setGender" -> {
//             val gender = call.argument<String>("gender")
//             safeyManagerWrapper.setGender(gender)
//         }
//         "setDateOfBirth" -> {
//             val year = call.argument<Int>("year")
//             val month = call.argument<Int>("month")
//             val day = call.argument<Int>("day")
//             safeyManagerWrapper.setDateOfBirth(year, month, day)
//         }
//         "setHeight" -> {
//             val height = call.argument<Int>("height")
//             safeyManagerWrapper.setHeight(height)
//         }
//         "setWeight" -> {
//             val weight = call.argument<Int>("weight")
//             safeyManagerWrapper.setWeight(weight)
//         }
//                 else -> {
//                     result.notImplemented()
//                 }
//             }
//         }
//     }
// }
