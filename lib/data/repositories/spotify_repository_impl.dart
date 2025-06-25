import 'package:dd2/domain/repositories/spotify_repository.dart';
import 'package:dd2/domain/entities/spotify_track.dart';
import 'package:dd2/domain/entities/lyric_data.dart';
import 'package:dd2/data/services/dummy_service.dart'; // DummyService 사용

class SpotifyRepositoryImpl implements SpotifyRepository {
  final DummySpotifyService _dummySpotifyService;

  SpotifyRepositoryImpl(this._dummySpotifyService);

  @override
  Stream<SpotifyTrack> get currentTrackStream => _dummySpotifyService.currentTrackStream.map((dummyTrack) => SpotifyTrack(
        id: dummyTrack.id,
        title: dummyTrack.title,
        artist: dummyTrack.artist,
        albumArtUrl: dummyTrack.albumArtUrl,
      ));

  @override
  Stream<LyricData> get currentLyricStream => _dummySpotifyService.currentLyricStream.map((dummyLyricData) => LyricData(
        lines: [], // TODO: 실제 lines로 변환 필요
      ));

  @override
  void nextTrack() {
    _dummySpotifyService.nextTrack();
  }

  @override
  void dispose() {
    _dummySpotifyService.dispose();
  }
} 