import 'package:dd2/domain/repositories/translation_repository.dart';

class TranslateLyricsUseCase {
  final TranslationRepository repository;

  TranslateLyricsUseCase(this.repository);

  Future<String> call(String text, String targetLanguage) {
    return repository.translateText(text, targetLanguage);
  }
} 