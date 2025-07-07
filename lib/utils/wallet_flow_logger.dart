import 'package:flutter/foundation.dart';


class WalletFlowLogger {

  ///Method for log as error
  static void error(dynamic message) {
    if (kDebugMode) {
      debugPrint(
        '\x1B[31mmWalletFlowError:${message == null ? '' : message.toString()}\x1B[0m',
      );
    }
  }

  ///Method for log as info
  static void info(dynamic message) {
    if (kDebugMode) debugPrint('\x1B[34mWalletFlowInfo:$message\x1B[0m');
  }

  ///Method for log as warning
  static void warning(dynamic message) {
    if (kDebugMode) {
      debugPrint('\x1B[33mmWalletFlowWarning:$message\x1B[0m');
    }
  }

}