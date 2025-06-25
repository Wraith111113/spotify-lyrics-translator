import 'package:dd2/domain/repositories/translation_repository.dart';
import 'package:dd2/data/services/translation_service.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationService _translationService;

  TranslationRepositoryImpl(this._translationService);

  @override
  Future<String> translateText(String text, String targetLanguage) {
    return _translationService.translate(text, targetLanguage);
  }
} 