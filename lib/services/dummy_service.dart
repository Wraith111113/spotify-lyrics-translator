import 'dart:async';
import 'package:flutter/foundation.dart';

class DummySpotifyService {
  final _dummyTracks = [
    DummyTrack(
        title: 'Dynamite',
        artist: 'BTS',
        lyrics:
            'Cause I-I-I\'m in the stars tonight\nSo watch me bring the fire and set the night alight',
        translation: '난 오늘 밤 별들 사이에 있으니\n내가 불을 지피고 밤을 밝히는 걸 지켜봐'),
    DummyTrack(
        title: '봄날',
        artist: 'BTS',
        lyrics: '보고 싶다 이렇게 말하니까 더\n보고 싶다 너희 사진을 보고 있어도',
        translation:
            'I miss you, saying this makes me miss you even more\nI miss you, even though I\'m looking at your picture'),
  ];

  int _currentIndex = 0;
  final _controller = StreamController<DummyTrack>.broadcast();

  DummySpotifyService() {
    _emitCurrent();
  }

  void _emitCurrent() {
    if (!_controller.isClosed) {
      _controller.add(_dummyTracks[_currentIndex]);
    }
  }

  Stream<DummyTrack> get currentTrackStream => _controller.stream;

  void nextTrack() {
    _currentIndex = (_currentIndex + 1) % _dummyTracks.length;
    _emitCurrent();
  }

  void dispose() {
    _controller.close();
  }
}

class DummyTrack {
  final String title;
  final String artist;
  final String lyrics;
  final String translation;

  DummyTrack({
    required this.title,
    required this.artist,
    required this.lyrics,
    required this.translation,
  });
}
