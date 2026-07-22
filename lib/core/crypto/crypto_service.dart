// lib/core/crypto/crypto_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:uuid/uuid.dart';

class CryptoService {
  // Generate a simple key pair
  Map<String, String> generateKeyPair() {
    final uuid = const Uuid().v4().replaceAll('-', '');
    return {'publicKey': 'PUBLIC_KEY_$uuid', 'privateKey': 'PRIVATE_KEY_$uuid'};
  }

  // Sign challenge with private key (Step 18)
  String signChallenge(String challenge, String privateKey) {
    // In production, use proper RSA signing
    // For demo, combine challenge with private key and encode
    final combined = '$challenge:$privateKey';
    final bytes = utf8.encode(combined);
    return base64Encode(bytes);
  }

  // Verify signature with public key (Step 20)
  bool verifySignature(String challenge, String signature, String publicKey) {
    try {
      final decoded = base64Decode(signature);
      final decodedString = utf8.decode(decoded);
      return decodedString.contains(challenge);
    } catch (e) {
      return false;
    }
  }
}
