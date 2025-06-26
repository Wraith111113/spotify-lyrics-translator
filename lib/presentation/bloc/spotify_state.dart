part of 'spotify_bloc.dart';

@immutable
abstract class SpotifyState {}

class SpotifyInitial extends SpotifyState {}

class SpotifyLoading extends SpotifyState {}

class SpotifyLoaded extends SpotifyState {
  final SpotifyTrack currentTrack;
  final String currentLyric;
  final String currentTranslation;

  SpotifyLoaded({
    required this.currentTrack,
    required this.currentLyric,
    required this.currentTranslation,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpotifyLoaded &&
          runtimeType == other.runtimeType &&
          currentTrack == other.currentTrack &&
          currentLyric == other.currentLyric &&
          currentTranslation == other.currentTranslation;

  @override
  int get hashCode => currentTrack.hashCode ^ currentLyric.hashCode ^ currentTranslation.hashCode;
}

class SpotifyNoTrack extends SpotifyState {}

class SpotifyError extends SpotifyState {
  final String message;

  SpotifyError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpotifyError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
} 