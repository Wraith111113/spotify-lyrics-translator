import 'translation_engine.dart';

class TranslationService {
  TranslationEngineType _selectedEngine = TranslationEngineType.dummy;
  final Map<TranslationEngineType, TranslationEngine> _engines = {
    TranslationEngineType.dummy: DummyTranslationEngine(),
    // 추후 실제 엔진 추가
  };

  void selectEngine(TranslationEngineType type) {
    _selectedEngine = type;
  }

  Future<String> translate(String text, String targetLang) {
    return _engines[_selectedEngine]!.translate(text, targetLang);
  }
} 