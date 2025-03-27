import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TranslateService {
  static const String _baseUrl = 'translation.googleapis.com';
  final String apiKey = dotenv.env['GOOGLE_TRANSLATE_API_KEY'] ?? '';

  Future<String?> translateText(String text, String targetLang) async {
    if (text.isEmpty) return null;

    try {
      final translateUri = Uri.https(_baseUrl, '/language/translate/v2', {
        'key': apiKey,
        'q': text,
        'target': targetLang,
      });

      final response = await http.post(translateUri);
      final data = jsonDecode(response.body);

      if (_isValidResponse(data)) {
        return _extractTranslation(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error translating text: $e');
      }
    }
    return null;
  }

  bool _isValidResponse(Map<String, dynamic> data) {
    return data['data'] != null &&
        data['data']['translations'] != null &&
        (data['data']['translations'] as List).isNotEmpty;
  }

  String _extractTranslation(Map<String, dynamic> data) {
    return data['data']['translations'][0]['translatedText'];
  }
}
