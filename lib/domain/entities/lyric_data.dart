import 'package:equatable/equatable.dart';

class LyricLine extends Equatable {
  final String text;
  final int startTime; // 초 단위
  final int endTime; // 초 단위
  final String? translation;

  const LyricLine({
    required this.text,
    required this.startTime,
    required this.endTime,
    this.translation,
  });

  @override
  List<Object?> get props => [text, startTime, endTime, translation];
}

class LyricData extends Equatable {
  final String lyrics;
  final String translation;
  final DateTime timestamp;

  const LyricData({
    required this.lyrics,
    required this.translation,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [lyrics, translation, timestamp];

  @override
  String toString() {
    return 'LyricData(lyrics: $lyrics, translation: $translation, timestamp: $timestamp)';
  }
}

/// 원문과 번역 가사 리스트를 타임스탬프별로 싱크하여 반환
List<LyricLine> syncLyricsWithTranslation({
  required List<LyricLine> originalLines,
  required List<LyricLine> translatedLines,
}) {
  List<LyricLine> synced = [];
  for (int i = 0; i < originalLines.length; i++) {
    final orig = originalLines[i];
    String? translation;
    if (i < translatedLines.length) {
      translation = translatedLines[i].text;
    }
    synced.add(LyricLine(
      text: orig.text,
      startTime: orig.startTime,
      endTime: orig.endTime,
      translation: translation,
    ));
  }
  return synced;
} 