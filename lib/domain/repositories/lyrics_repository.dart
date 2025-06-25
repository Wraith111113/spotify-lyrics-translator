import 'package:dd2/domain/entities/lyric_data.dart';

abstract class LyricsRepository {
  Future<LyricData> getLyricsForTrack(String trackId);
} 