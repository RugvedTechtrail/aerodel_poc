import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'poc_safey_method_channel.dart';

abstract class PocSafeyPlatform extends PlatformInterface {
  /// Constructs a PocSafeyPlatform.
  PocSafeyPlatform() : super(token: _token);

  static final Object _token = Object();

  static PocSafeyPlatform _instance = MethodChannelPocSafey();

  /// The default instance of [PocSafeyPlatform] to use.
  ///
  /// Defaults to [MethodChannelPocSafey].
  static PocSafeyPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PocSafeyPlatform] when
  /// they register themselves.
  static set instance(PocSafeyPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool?> getConnected() {
    throw UnimplementedError('getConnected() has not been implemented.');
  }

  Future<void> scanDevices() {
    throw UnimplementedError('scanDevices() has not been implemented.');
  }

  Future<void> connectDevice() {
    throw UnimplementedError('connectDevice() has not been implemented.');
  }

  Future<void> disconnectDevice() {
    throw UnimplementedError('disconnectDevice() has not been implemented.');
  }

  Future<void> startTrial() {
    throw UnimplementedError('startTrial() has not been implemented.');
  }

  Future<void> setFirstName(String firstName) {
    throw UnimplementedError('setFirstName() has not been implemented.');
  }

  Future<void> setLastName(String lastName) {
    throw UnimplementedError('setLastName() has not been implemented.');
  }

  Future<void> setGender(String gender) {
    throw UnimplementedError('setGender() has not been implemented.');
  }

  Future<void> setDateOfBirth(int year, int month, int day) {
    throw UnimplementedError('setDateOfBirth() has not been implemented.');
  }

  Future<void> setHeight(int height) {
    throw UnimplementedError('setHeight() has not been implemented.');
  }

  Future<void> setWeight(int weight) {
    throw UnimplementedError('setWeight() has not been implemented.');
  }
}
