import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'poc_safey_background_channel.dart';

abstract class PocSafeyBackgroundPlatform extends PlatformInterface {
  /// Constructs a PocSafeyBackgroundPlatform.
  PocSafeyBackgroundPlatform() : super(token: _token);

  static final Object _token = Object();

  static PocSafeyBackgroundPlatform _instance = BackgroundChannelPocSafey();

  /// The default instance of [PocSafeyBackgroundPlatform] to use.
  ///
  /// Defaults to [MethodChannelPocSafey].
  static PocSafeyBackgroundPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PocSafeyBackgroundPlatform] when
  /// they register themselves.
  static set instance(PocSafeyBackgroundPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}
