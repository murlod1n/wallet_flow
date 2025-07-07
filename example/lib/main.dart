import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wallet_flow/wallet_flow.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    //Check wallet available
    WalletFlow.checkAvailable().then((isAvailable) {
      print(isAvailable);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet Flow Plugin'),
        ),
        body: Padding(
          padding: EdgeInsets.all(22),
          child: Column(
            spacing: 22,
            children: [

              // Autodetect platform
              AddCardToWalletButton(
                onPressed: () async {
                  if(Platform.isAndroid) {
                    final res = await WalletFlow
                      .addCardToGoogleWalletFromToken(googleWalletPassData: "YOUR_JWT");
                  } else if(Platform.isIOS) {
                    final res = await WalletFlow
                      .addCardToAppleWalletFromUrl(url: "YOUR_URL");
                  }

                },
              ),

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
                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
