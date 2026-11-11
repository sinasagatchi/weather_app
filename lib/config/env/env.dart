import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get weatherapiKey {
    if (!dotenv.isInitialized) return '';
    final key = dotenv.env['weatherapiKey']?.trim() ?? '';
    final normalizedKey = key.toLowerCase();
    if (key.isEmpty ||
        normalizedKey.contains('your_weatherapi_key') ||
        normalizedKey.contains('here_your_weatherapi')) {
      return '';
    }
    return key;
  }
}
