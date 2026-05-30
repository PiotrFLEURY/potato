import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

class EncryptionService {
  static const _charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const _codeLength = 8;
  static const _salt = String.fromEnvironment(
    'ENCRYPTION_SALT',
    defaultValue: 'potato_enc_v1',
  );

  static final _cipher = AesGcm.with256bits();
  static final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  static String generateCode() {
    final rng = Random.secure();
    return List.generate(
      _codeLength,
      (_) => _charset[rng.nextInt(_charset.length)],
    ).join();
  }

  static Future<String> hashRoomCode(String code) async {
    Sha256 sha256 = Sha256();
    final hash = await sha256.hash(utf8.encode(code));
    final result = hash.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    if (kDebugMode) {
      print('Hashing room code: $code -> $result');
    }
    return result;
  }

  static Future<SecretKey> _deriveKey(String code) {
    return _hkdf.deriveKey(
      secretKey: SecretKey(utf8.encode(code)),
      nonce: utf8.encode(_salt),
    );
  }

  // Returns: nonce(12) + mac(16) + ciphertext
  static Future<Uint8List> encryptBytes(
    String code,
    Uint8List plaintext,
  ) async {
    final key = await _deriveKey(code);
    final box = await _cipher.encrypt(plaintext, secretKey: key);
    return Uint8List.fromList([
      ...box.nonce,
      ...box.mac.bytes,
      ...box.cipherText,
    ]);
  }

  // Expects: nonce(12) + mac(16) + ciphertext
  static Future<Uint8List> decryptBytes(
    String code,
    Uint8List encrypted,
  ) async {
    final key = await _deriveKey(code);
    final nonce = encrypted.sublist(0, 12);
    final mac = Mac(encrypted.sublist(12, 28));
    final cipherText = encrypted.sublist(28);
    final plaintext = await _cipher.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: key,
    );
    return Uint8List.fromList(plaintext);
  }

  static Future<String> encryptString(String code, String plaintext) async {
    final encrypted = await encryptBytes(
      code,
      Uint8List.fromList(utf8.encode(plaintext)),
    );
    return base64Url.encode(encrypted);
  }

  static Future<String> decryptString(String code, String encrypted) async {
    final bytes = base64Url.decode(encrypted);
    final plaintext = await decryptBytes(code, bytes);
    return utf8.decode(plaintext);
  }
}
