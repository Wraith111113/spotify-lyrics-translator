part of 'spotify_bloc.dart';

@immutable
abstract class SpotifyEvent {}

class LoadCurrentTrack extends SpotifyEvent {}

class UpdateLyric extends SpotifyEvent {
  final String lyric;
  final String translation;

  UpdateLyric(this.lyric, this.translation);
}

class NextTrack extends SpotifyEvent {} 