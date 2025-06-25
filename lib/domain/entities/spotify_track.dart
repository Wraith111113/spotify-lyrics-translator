import 'package:equatable/equatable.dart';

class SpotifyTrack extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String albumArtUrl;

  const SpotifyTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArtUrl,
  });

  @override
  List<Object> get props => [id, title, artist, albumArtUrl];
} 