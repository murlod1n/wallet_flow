import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/wallet_flow_constants.dart';
import 'add_card_to_wallet_button_interface.dart';

/// Main public widget to display an "Add to Wallet" button on supported platforms.
///
/// This widget abstracts the platform differences:
/// - On iOS, it uses a native Apple Wallet button (`PKAddPassButton`),
///   rendered via a `UiKitView`.
/// - On Android, it uses a native Google Wallet button,
///   rendered via an `AndroidView`.
///
/// Throws `UnsupportedError` if the current platform is not iOS or Android.
///
/// Example usage:
/// ```dart
/// AddCardToWalletButton(
///   onPressed: () {
///     // Handle the button tap
///   },
/// );
/// ```
///
/// You can also create platform-specific buttons explicitly:
/// ```dart
/// AddCardToWalletButton.apple(onPressed: () { ... });
/// AddCardToWalletButton.google(onPressed: () { ... }, locale: Locale('en'));
/// ```
///
/// ## Parameters:
/// - `onPressed`: A callback fired when the button is pressed.
/// - `locale`: (Android only) Locale to be passed to the native Google Wallet button
///   for localization purposes.
class AddCardToWalletButton extends AddCardToWalletButtonInterface {
  /// Creates a platform-aware Add to Wallet button.
  ///
  /// Automatically chooses the appropriate native button for iOS and Android.
  ///
  /// Throws [UnsupportedError] on unsupported platforms.
  const AddCardToWalletButton({
    super.key,
    required super.onPressed,
    super.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _AddCardToAppleWalletButton(onPressed: super.onPressed);
    } else if (Platform.isAndroid) {
      return _AddCardToGoogleWalletButton(onPressed: super.onPressed);
    } else {
      throw UnsupportedError(
        'AddCardToWalletButton is only supported on iOS and Android',
      );
    }
  }

  /// Creates the native Apple Wallet button widget.
  ///
  /// Throws [UnsupportedError] if used on non-iOS platforms.
  factory AddCardToWalletButton.apple({required VoidCallback? onPressed}) {
    if (!Platform.isIOS) {
      throw UnsupportedError(
        'AddCardToWalletButton.apple is only supported on iOS',
      );
    }

    return _AddCardToAppleWalletButton(onPressed: onPressed);
  }

  /// Creates the native Google Wallet button widget.
  ///
  /// Accepts an optional [locale] to localize the button.
  factory AddCardToWalletButton.google({
    required VoidCallback? onPressed,
    Locale? locale,
  }) {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'AddCardToWalletButton.google is only supported on Android',
      );
    }

    return _AddCardToGoogleWalletButton(onPressed: onPressed, locale: locale);
  }
}

/// Private widget rendering the Apple Wallet button on iOS.
///
/// Wraps a native `PKAddPassButton` rendered using `UiKitView`.
/// The button automatically adapts to the system locale.
///
/// Does not accept additional parameters.
class _AddCardToAppleWalletButton extends AddCardToWalletButton {
  const _AddCardToAppleWalletButton({required super.onPressed});



  @override
  Widget build(BuildContext context) {

    MethodChannel(WalletFlowChannel.name).setMethodCallHandler((call) async {
      if (call.method == NativePlatformViews.addCardToAppleWalletCallback) {
        super.onPressed!();
      }
    });

    return ClipRRect(
      borderRadius: super.borderRadius ?? BorderRadius.circular(0),
      child: SizedBox(
        height: 54,
        child: UiKitView(
          viewType: NativePlatformViews.appleWalletButton,
          layoutDirection: TextDirection.ltr,
          creationParams: {},
          creationParamsCodec: const StandardMessageCodec(),
        ),
      ),
    );
  }
}

/// Private widget rendering the Google Wallet button on Android.
///
/// Wraps a native Google Wallet button rendered using `AndroidView`.
/// Supports passing an optional [locale] for localization.
///
/// The native button uses the locale parameter to display the button
/// in the correct language.
class _AddCardToGoogleWalletButton extends AddCardToWalletButton {
  const _AddCardToGoogleWalletButton({required super.onPressed, this.locale});

  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    MethodChannel(WalletFlowChannel.name).setMethodCallHandler((call) async {
      if (call.method == NativePlatformViews.googleWalletButtonCallback) {
        super.onPressed!();
      }
    });

    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{
      WalletFlowChannelPropsKeys.locale: locale?.languageCode,
    };

    return ClipRRect(
      borderRadius: super.borderRadius ?? BorderRadius.circular(0),
      child: SizedBox(
        height: 54,
        child: AndroidView(
          viewType: NativePlatformViews.googleWalletButton,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      ),
    );
  }
}
