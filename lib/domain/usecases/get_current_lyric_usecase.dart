import 'package:dd2/domain/entities/lyric_data.dart';
import 'package:dd2/domain/repositories/spotify_repository.dart';

class GetCurrentLyricUseCase {
  final SpotifyRepository repository;

  GetCurrentLyricUseCase(this.repository);

  Stream<LyricData> call() {
    return repository.currentLyricStream;
  }
} 