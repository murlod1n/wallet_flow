import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Utility class for working with PKPass files and converting them
/// to a base64 encoded string.
class WalletFlowUtils {
  /// Reads a PKPass file from the local filesystem at the given [path]
  /// and returns its contents encoded as a base64 string.
  ///
  /// The [path] parameter is the full file path to the PKPass file.
  ///
  /// Returns a [Future] that completes with the base64-encoded string,
  /// which can be used, for example, to pass the data to a plugin.
  ///
  /// Throws an [IOException] if the file is not found or cannot be read.
  static Future<String> loadPkpassFileAsBase64({required String path}) async {
    final bytes = await File(path).readAsBytes();
    return base64Encode(bytes);
  }

  /// Downloads a PKPass file from the specified [url] and returns its contents
  /// encoded as a base64 string.
  ///
  /// The [url] parameter should point to a valid PKPass file on the internet.
  /// Optional [headers] can be provided for the HTTP GET request.
  ///
  /// Returns a [Future] that completes with the base64-encoded string
  /// if the download is successful.
  ///
  /// Throws an [Exception] if the file could not be downloaded or the response
  /// has a status code other than 200.
  static Future<String> loadPkpassFileFromNetworkAsBase64({
    required String url,
    Map<String, String>? headers,
  }) async {

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      return base64Encode(bytes);
    } else {
      throw Exception('Failed to download pkpass file: ${response.statusCode}');
    }
  }

}
