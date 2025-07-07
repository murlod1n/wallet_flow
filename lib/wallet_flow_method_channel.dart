import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wallet_flow/constants/wallet_flow_constants.dart';

import 'wallet_flow_platform_interface.dart';

/// An implementation of [WalletFlowPlatform] that uses method channels.
class MethodChannelWalletFlow extends WalletFlowPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('wallet_flow');

  @override
  Future<bool> addCardToGoogleWallet(String passData) async {
    final isAdded = await methodChannel.invokeMethod<bool>(WalletFlowChannelMethods.addCardToGoogleWallet, {'token': passData});
    return isAdded ?? false;
  }

  @override
  Future<bool> addCardToAppleWallet(String passData) async {
    final isAdded = await methodChannel.invokeMethod<bool>(WalletFlowChannelMethods.addCardToAppleWallet, {'passData': passData});
    return isAdded ?? false;
  }

  @override
  Future<bool> checkAvailable() async {
    final isAvailable = await methodChannel.invokeMethod<bool>(WalletFlowChannelMethods.checkAvailable);
    return isAvailable ?? false;
  }

}
