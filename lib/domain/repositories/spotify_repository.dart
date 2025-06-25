import 'package:dd2/domain/entities/spotify_track.dart';
import 'package:dd2/domain/entities/lyric_data.dart';

abstract class SpotifyRepository {
  Stream<SpotifyTrack> get currentTrackStream;
  Stream<LyricData> get currentLyricStream;
  void nextTrack();
  void dispose();
} 