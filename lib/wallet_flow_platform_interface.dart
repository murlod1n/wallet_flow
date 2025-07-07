import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'wallet_flow_method_channel.dart';

abstract class WalletFlowPlatform extends PlatformInterface {
  /// Constructs a WalletFlowPlatform.
  WalletFlowPlatform() : super(token: _token);

  static final Object _token = Object();

  static WalletFlowPlatform _instance = MethodChannelWalletFlow();

  /// The default instance of [WalletFlowPlatform] to use.
  ///
  /// Defaults to [MethodChannelWalletFlow].
  static WalletFlowPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WalletFlowPlatform] when
  /// they register themselves.
  static set instance(WalletFlowPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> checkAvailable() {
    throw UnimplementedError('checkAvailable() has not been implemented.');
  }

  Future<bool> addCardToGoogleWallet(String passData) {
    throw UnimplementedError('addCardToGoogleWallet() has not been implemented.');
  }

  Future<bool> addCardToAppleWallet(String passData) {
    throw UnimplementedError('addCardToAppleWallet() has not been implemented.');
  }

}
