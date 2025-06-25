import 'package:dd2/domain/entities/spotify_track.dart';
import 'package:dd2/domain/repositories/spotify_repository.dart';

class GetCurrentTrackUseCase {
  final SpotifyRepository repository;

  GetCurrentTrackUseCase(this.repository);

  Stream<SpotifyTrack> call() {
    return repository.currentTrackStream;
  }
} 