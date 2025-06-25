import 'package:dd2/domain/entities/lyric_data.dart';

abstract class TranslationRepository {
  Future<String> translateText(String text, String targetLanguage);
} 