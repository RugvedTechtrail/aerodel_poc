import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'poc_safey_background_interface.dart';

/// An implementation of [PocSafeyBackgroundPlatform] that uses method channels.
class BackgroundChannelPocSafey extends PocSafeyBackgroundPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('background_poc_safey');

  BackgroundChannelPocSafey() {
    methodChannel.setMethodCallHandler(_handleMethod);
  }
  late Function(Map<String, dynamic> progressData) onProgressUpdate;

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
    }
  }

  late Function(Object device) onDeviceDiscovered;

  late Function(String deviceId) onLastConnectedDevice;

  late Function(String error) onError;
}
