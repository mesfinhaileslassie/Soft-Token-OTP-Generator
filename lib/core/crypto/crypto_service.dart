// lib/core/crypto/crypto_service.dart

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart';

class CryptoService {
  // ============================================================
  // RSA KEY GENERATION
  // ============================================================

  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAKeyPair() {
    final secureRandom = _createSecureRandom();

    final keyGenerator = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
          secureRandom,
        ),
      );

    final pair = keyGenerator.generateKeyPair();

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      pair.publicKey as RSAPublicKey,
      pair.privateKey as RSAPrivateKey,
    );
  }

  static SecureRandom _createSecureRandom() {
    final secureRandom = FortunaRandom();

    final random = Random.secure();

    final seed = Uint8List(32);

    for (int i = 0; i < seed.length; i++) {
      seed[i] = random.nextInt(256);
    }

    secureRandom.seed(KeyParameter(seed));

    return secureRandom;
  }

  // ============================================================
  // EXPORT KEYS TO PEM
  // ============================================================

  static String exportPublicKeyToPEM(PublicKey publicKey) {
    final rsaKey = publicKey as RSAPublicKey;

    return CryptoUtils.encodeRSAPublicKeyToPemPkcs1(rsaKey);
  }

  static String exportPrivateKeyToPEM(PrivateKey privateKey) {
    final rsaKey = privateKey as RSAPrivateKey;

    return CryptoUtils.encodeRSAPrivateKeyToPemPkcs1(rsaKey);
  }

  // ============================================================
  // IMPORT KEYS FROM PEM
  // ============================================================

  static RSAPublicKey parsePublicKey(String pem) {
    return CryptoUtils.rsaPublicKeyFromPemPkcs1(pem);
  }

  static RSAPrivateKey parsePrivateKey(String pem) {
    return CryptoUtils.rsaPrivateKeyFromPemPkcs1(pem);
  }

  // ============================================================
  // SIGN CHALLENGE
  // ============================================================

  static String signChallenge(String challenge, String privateKeyPEM) {
    try {
      final privateKey = parsePrivateKey(privateKeyPEM);

      final signer = Signer('SHA-256/RSA');

      signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

      final data = Uint8List.fromList(utf8.encode(challenge));

      final signature = signer.generateSignature(data) as RSASignature;

      return base64Encode(signature.bytes);
    } catch (e, stack) {
      print("SIGN ERROR: $e");

      print(stack);

      rethrow;
    }
  }

  // ============================================================
  // VERIFY SIGNATURE
  // ============================================================

  static bool verifySignature(
    String challenge,
    String signatureBase64,
    String publicKeyPEM,
  ) {
    try {
      final publicKey = parsePublicKey(publicKeyPEM);

      final signer = Signer('SHA-256/RSA');

      signer.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));

      final data = Uint8List.fromList(utf8.encode(challenge));

      final signature = RSASignature(base64Decode(signatureBase64));

      return signer.verifySignature(data, signature);
    } catch (e, stack) {
      print("VERIFY ERROR: $e");

      print(stack);

      return false;
    }
  }
}
