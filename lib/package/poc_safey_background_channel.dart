import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'poc_safey_background_interface.dart';

class BackgroundChannelPocSafey extends PocSafeyBackgroundPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('background_poc_safey');

  BackgroundChannelPocSafey() {
    methodChannel.setMethodCallHandler(_handleMethod);
  }

  late Function(Map<String, dynamic> progressData) onProgressUpdate;
  late Function(Object device) onDeviceDiscovered;
  late Function(String deviceId) onLastConnectedDevice;
  late Function(String error) onError;
  late Function(String filePath) onTestFileGenerated; // Add this line

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onDeviceDiscovered':
        return onDeviceDiscovered(call.arguments);
      case 'onLastConnectedDevice':
        return onLastConnectedDevice(call.arguments);
      case 'onError':
        return onError(call.arguments);
      case 'onProgressUpdate':
        return onProgressUpdate(Map<String, dynamic>.from(call.arguments));
      case 'onTestFileGenerated': // Add this case
        return onTestFileGenerated(call.arguments as String);
    }
  }
}
