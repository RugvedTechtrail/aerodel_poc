import 'dart:developer';

import 'poc_safey_background_channel.dart';
import 'poc_safey_platform_interface.dart';

class PocSafey extends BackgroundChannelPocSafey {
  Future<bool?> getConnected() {
    return PocSafeyPlatform.instance.getConnected();
  }

  Future<void> scanDevices() {
    log('raff sgg svfv');
    return PocSafeyPlatform.instance.scanDevices();
  }

  Future<void> connectDevice() {
    log('in connect device funciton retunign instanec');
    return PocSafeyPlatform.instance.connectDevice();
  }

  Future<void> disconnectDevice() {
    return PocSafeyPlatform.instance.disconnectDevice();
  }

  Future<void> startTrial() {
    return PocSafeyPlatform.instance.startTrial();
  }

  Future<void> setFirstName(String firstName) {
    return PocSafeyPlatform.instance.setFirstName(firstName);
  }

  Future<void> setLastName(String lastName) {
    return PocSafeyPlatform.instance.setLastName(lastName);
  }

  Future<void> setGender(String gender) {
    return PocSafeyPlatform.instance.setGender(gender);
  }

  Future<void> setDateOfBirth(String value) {
    final parts = value.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    return PocSafeyPlatform.instance.setDateOfBirth(year, month, day);
  }

  Future<void> setHeight(String height) {
    return PocSafeyPlatform.instance.setHeight(int.parse(height));
  }

  Future<void> setWeight(String weight) {
    return PocSafeyPlatform.instance.setWeight(int.parse(weight));
  }
}
