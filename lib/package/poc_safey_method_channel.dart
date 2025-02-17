import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'poc_safey_platform_interface.dart';

/// An implementation of [PocSafeyPlatform] that uses method channels.
class MethodChannelPocSafey extends PocSafeyPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('poc_safey');

  @override
  Future<bool?> getConnected() async {
    final connected = await methodChannel.invokeMethod<bool>('getConnected');
    return connected;
  }

  @override
  Future<void> scanDevices() async {
    await methodChannel.invokeMethod<void>('scanDevices');
  }

  @override
  Future<void> connectDevice() async {
    await methodChannel.invokeMethod<void>('connectDevice');
  }

  @override
  Future<void> disconnectDevice() async {
    await methodChannel.invokeMethod<void>('disconnectDevice');
  }

  @override
  Future<void> startTrial() async {
    await methodChannel.invokeMethod<void>('startTrial');
  }

  @override
  Future<void> setFirstName(String firstName) async {
    await methodChannel.invokeMethod<void>('setFirstName', {'firstName': firstName});
  }

  @override
  Future<void> setLastName(String lastName) async {
    await methodChannel.invokeMethod<void>('setLastName', {'lastName': lastName});
  }

  @override
  Future<void> setGender(String gender) async {
    await methodChannel.invokeMethod<void>('setGender', {'gender': gender});
  }

  @override
  Future<void> setDateOfBirth(int year, int month, int day) async {
    await methodChannel.invokeMethod<void>('setDateOfBirth', <String, int>{
      'year': year,
      'month': month,
      'day': day,
    });
  }

  @override
  Future<void> setHeight(int height) async {
    await methodChannel.invokeMethod<void>('setHeight', {'height': height});
  }

  @override
  Future<void> setWeight(int weight) async {
    await methodChannel.invokeMethod<void>('setWeight', {'weight': weight});
  }
}
