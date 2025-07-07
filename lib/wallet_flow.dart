import 'dart:io';

import 'package:wallet_flow/utils/wallet_flow_utils.dart';

import 'wallet_flow_platform_interface.dart';
export 'widgets/add_card_to_wallet_button.dart';

/// A class that provides methods to interact with the native wallet
/// functionalities on Android and iOS platforms.
class WalletFlow {
  /// Checks if the wallet functionality is available on the current platform.
  /// Returns `true` if available, `false` otherwise.
  static Future<bool> checkAvailable() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return WalletFlowPlatform.instance.checkAvailable();
    }
    return Future.error(Exception('Platform is not supported.'));
  }

  /// Adds a card to Google Wallet using a token.
  ///
  /// [googleWalletPassData] is the token provided by the server to add the card.
  /// This method is only available on Android.
  /// Returns `true` if the card was added successfully, `false` otherwise.
  static Future<bool> addCardToGoogleWalletFromToken({
    required String googleWalletPassData,
  }) async {
    if (!Platform.isAndroid) {
      return Future.error(
        Exception('Google Wallet is only available on Android.'),
      );
    }
    return WalletFlowPlatform.instance.addCardToGoogleWallet(
      googleWalletPassData,
    );
  }

  /// Adds a card to Apple Wallet using a base64 encoded token.
  ///
  /// [appleWalletPassData] is the base64 encoded token provided by the server to add the card.
  /// This method is only available on iOS.
  /// Returns `true` if the card was added successfully, `false` otherwise.
  static Future<bool> addCardToAppleWalletFromBase64Token({
    required String appleWalletPassData,
  }) async {
    if (!Platform.isIOS) {
      return Future.error(Exception('Apple Wallet is only available on iOS.'));
    }
    return WalletFlowPlatform.instance
        .addCardToAppleWallet(appleWalletPassData);
  }

  /// Adds a card to Apple Wallet from a local .pkpass file.
  ///
  /// [path] is the local path to the .pkpass file.
  /// This method is only available on iOS.
  /// Returns `true` if the card was added successfully, `false` otherwise.
  /// Throws an error if the file cannot be loaded or if the platform is not iOS.
  static Future<bool> addCardToAppleWalletFromPath({
    required String path,
  }) async {
    if (!Platform.isIOS) {
      return Future.error(Exception('Apple Wallet is only available on iOS.'));
    }

    final base64 = await WalletFlowUtils.loadPkpassFileAsBase64(path: path);

    return WalletFlowPlatform.instance
        .addCardToAppleWallet(base64);
  }

  /// Adds a card to Apple Wallet from a .pkpass file hosted online.
  ///
  /// [url] is the URL to the .pkpass file.
  /// [headers] are optional headers for the HTTP request.
  /// This method is only available on iOS.
  /// Returns `true` if the card was added successfully, `false` otherwise.
  /// Throws an error if the file cannot be downloaded or if the platform is not iOS.
  static Future<bool> addCardToAppleWalletFromUrl({
    required String url,
    Map<String, String>? headers,
  }) async {
    if (!Platform.isIOS) {
      return Future.error(Exception('Apple Wallet is only available on iOS.'));
    }

    final base64 = await WalletFlowUtils.loadPkpassFileFromNetworkAsBase64(url: url, headers: headers);

    return WalletFlowPlatform.instance
      .addCardToAppleWallet(base64);
  }
}
