import 'package:dd2/domain/repositories/spotify_repository.dart';

class GetNextTrackUseCase {
  final SpotifyRepository repository;

  GetNextTrackUseCase(this.repository);

  void call() {
    repository.nextTrack();
  }
} 