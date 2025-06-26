import 'package:equatable/equatable.dart';

class SpotifyTrack extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String albumArtUrl;
  final bool isPlaying;

  const SpotifyTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArtUrl,
    required this.isPlaying,
  });

  @override
  List<Object?> get props => [id, title, artist, albumArtUrl, isPlaying];

  @override
  String toString() {
    return 'SpotifyTrack(id: $id, title: $title, artist: $artist, isPlaying: $isPlaying)';
  }
} 