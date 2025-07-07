# wallet_flow

This plugin allows you to add cards to google and apple wallet.

You can also use the plugin to embed native "Add to Wallet" buttons with localization support.

|             | Android | iOS   |
|-------------|---------|-------|
| **Support** | SDK 21+ | 12.0+ |



<p>
  <img src="https://github.com/murlod1n/wallet_flow/raw/main/assets/google_wallet.png"
    alt="Google Wallet Button" height="400"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://github.com/murlod1n/wallet_flow/raw/main/assets/apple_wallet.png"
   alt="Apple Wallet Button" height="400"/>
</p>

## Features

Use this plugin in your Flutter app to:

* Displaying native "Add to Wallet" buttons
* Checking wallet availability
* Adding cards to Google and Apple wallets

## Getting started

This plugin uses the native Apple Wallet and Google Wallet to add cards.
It provides a single platform, but you still need to understand and configure it.
each service has its own application. The guides will be presented below.

* [Apple Wallet documentation](https://developer.apple.com/documentation/walletpasses)
* [Google Wallet documentation](https://developers.google.com/wallet/generic?hl=en)

> NOTE:  In the current version of the plugin, adding a card to Google Wallet requires JWT,
> and to work with Apple Wallet, you can transfer a file in base64 format,
> or specify the path (link) to the file.


## Examples

Checking wallet availability:

```dart
@override
void initState() {
  WalletFlow.checkAvailable().then((isAvailable) {
    print(isAvailable);
  });
  super.initState();
}
```

A button with automatic platform detection(IOS, Android):

```dart
AddCardToWalletButton(
  onPressed: () async {
    if(Platform.isAndroid) {
      inal res = await WalletFlow
        .addCardToGoogleWalletFromToken(googleWalletPassData: "YOUR_JWT");
    } else if(Platform.isIOS) {
      final res = await WalletFlow
        .addCardToAppleWalletFromUrl(url: "YOUR_URL");
    }
  },
),
```

The "Add to Google Wallet" button. 
This button supports the `locale` parameter. 
Returns `true` if the card was successfully added and reopened, 
and `false` if the card was not added.:

```dart
if(Platform.isAndroid)
  SizedBox(
    height: 54,
    child: AddCardToWalletButton.google(
      locale: Locale("ru"),
      onPressed: () async {
        final res = await WalletFlow
          .addCardToGoogleWalletFromToken(googleWalletPassData: "YOUR_JWT");
      }
    ),
  )
```

The "Add to Apple Wallet" button. 
After the user closes the window to add the card, 
regardless of whether he added it or not, it will return `true`:

```dart
if(Platform.isIOS)
  SizedBox(
    height: 54,
    child: AddCardToWalletButton.apple(
      onPressed: () async {
        final res = await WalletFlow
          .addCardToAppleWalletFromUrl(url: "YOUR_URL");
      }
    ),
  )
```

> NOTE:  You can easily use adding card in your scenarios outside of native buttons.

## Roadmap 
* Add white and white with a black outline variations for "Add to Google Wallet".

## Contributing to this plugin

If you would like to contribute to the plugin, check out our
[GitHub](https://github.com/murlod1n/wallet_flow).