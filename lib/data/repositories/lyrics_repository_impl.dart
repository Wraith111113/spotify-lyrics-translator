import 'package:dd2/domain/repositories/lyrics_repository.dart';
import 'package:dd2/domain/entities/lyric_data.dart';
import 'package:dd2/data/services/lyrics_service.dart';

class LyricsRepositoryImpl implements LyricsRepository {
  final LyricsService _lyricsService;

  LyricsRepositoryImpl(this._lyricsService);

  @override
  Future<LyricData> getLyricsForTrack(String trackId) async {
    // Dummy service doesn't use trackId, so we will just return sample data
    // In a real application, you would use trackId to fetch specific lyrics
    final currentLyricData = await _lyricsService.getCurrentLyricData(trackId);
    return LyricData(lyrics: currentLyricData.lyrics, translation: currentLyricData.translation);
  }
} 