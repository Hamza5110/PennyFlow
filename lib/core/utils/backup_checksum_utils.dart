import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Integrity helpers for backup bundles (FR-145).
abstract final class BackupChecksumUtils {
  static String sha256OfBytes(List<int> bytes) =>
      sha256.convert(bytes).toString();

  static String sha256OfFile(File file) =>
      sha256OfBytes(file.readAsBytesSync());

  static Future<String> sha256OfFileAsync(File file) async =>
      sha256OfBytes(await file.readAsBytes());

  static bool verifySha256(List<int> bytes, String expected) =>
      sha256OfBytes(bytes) == expected.toLowerCase();

  static Map<String, dynamic> decodeJsonFile(File file) =>
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

  static Future<void> writeJsonFile(File file, Map<String, dynamic> json) async {
    final encoded = const JsonEncoder.withIndent('  ').convert(json);
    await file.writeAsString(encoded);
  }

  static Uint8List utf8Bytes(String value) => Uint8List.fromList(utf8.encode(value));
}
