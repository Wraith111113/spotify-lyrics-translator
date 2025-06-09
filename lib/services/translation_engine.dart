enum TranslationEngineType { dummy, papago, google, deepl }

abstract class TranslationEngine {
  Future<String> translate(String text, String targetLang);
}

class DummyTranslationEngine implements TranslationEngine {
  @override
  Future<String> translate(String text, String targetLang) async {
    return '[${targetLang.toUpperCase()}] $text (더미 번역)';
  }
} 