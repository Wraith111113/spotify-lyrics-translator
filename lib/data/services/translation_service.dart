import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'translation_engine.dart';

class TranslationService {
  TranslationEngineType _selectedEngine = TranslationEngineType.google;
  final Map<TranslationEngineType, TranslationEngine> _engines = {
    TranslationEngineType.dummy: DummyTranslationEngine(),
    TranslationEngineType.google: GoogleTranslationEngine(),
    // 추후 다른 엔진 추가 가능
  };

  void selectEngine(TranslationEngineType type) {
    _selectedEngine = type;
  }

  Future<String> translate(String text, String targetLang) async {
    if (text.isEmpty) return '';
    
    try {
      return await _engines[_selectedEngine]!.translate(text, targetLang);
    } catch (e) {
      print('번역 오류: $e');
      // 번역 실패 시 원본 텍스트 반환
      return text;
    }
  }

  // 한국어로 번역하는 편의 메서드
  Future<String> translateToKorean(String text) {
    return translate(text, 'ko');
  }
}

class GoogleTranslationEngine implements TranslationEngine {
  static const String _baseUrl = 'https://translation.googleapis.com/language/translate/v2';
  
  @override
  Future<String> translate(String text, String targetLang) async {
    try {
      final apiKey = dotenv.env['GOOGLE_TRANSLATE_API_KEY'];
      
      if (apiKey == null) {
        throw Exception('Google Translate API 키가 설정되지 않았습니다.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'q': text,
          'target': targetLang,
          'source': 'auto', // 자동 언어 감지
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translations = data['data']['translations'] as List;
        
        if (translations.isNotEmpty) {
          return translations[0]['translatedText'] as String;
        }
      } else {
        throw Exception('번역 API 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('Google 번역 오류: $e');
      // API 오류 시 더미 번역으로 폴백
      return '[번역] $text';
    }
    
    return text;
  }
} 