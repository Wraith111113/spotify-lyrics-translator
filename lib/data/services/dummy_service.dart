import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/lyric_data.dart';

class DummySpotifyService {
  final _dummyTracks = [
    DummyTrack(id: '1', title: 'Dynamite', artist: 'BTS', albumArtUrl: '', lyricsTimeline: [
      LyricLine(
          text: 'Cause I-I-I\'m in the stars tonight',
          startTime: 0,
          endTime: 3),
      LyricLine(
          text: 'So watch me bring the fire and set the night alight',
          startTime: 3,
          endTime: 6),
      LyricLine(
          text: 'Shoes on, get up in the morn\'', startTime: 6, endTime: 9),
      LyricLine(
          text: 'Cup of milk, let\'s rock and roll', startTime: 9, endTime: 12),
      LyricLine(text: 'King Kong, kick the drum', startTime: 12, endTime: 15),
      LyricLine(
          text: 'Rolling on like a Rolling Stone', startTime: 15, endTime: 18),
      LyricLine(
          text: 'Sing song when I\'m walking home', startTime: 18, endTime: 21),
      LyricLine(text: 'Jump up to the top, LeBron', startTime: 21, endTime: 24),
    ], translationTimeline: [
      LyricLine(text: '난 오늘 밤 별들 사이에 있으니', startTime: 0, endTime: 3),
      LyricLine(text: '내가 불을 지피고 밤을 밝히는 걸 지켜봐', startTime: 3, endTime: 6),
      LyricLine(text: '신발 신고, 아침에 일어나', startTime: 6, endTime: 9),
      LyricLine(text: '우유 한 잔, 신나게 달려보자', startTime: 9, endTime: 12),
      LyricLine(text: '킹콩, 드럼을 두드려', startTime: 12, endTime: 15),
      LyricLine(text: '롤링 스톤처럼 굴러가며', startTime: 15, endTime: 18),
      LyricLine(text: '집으로 걸어갈 때 노래를 불러', startTime: 18, endTime: 21),
      LyricLine(text: '르브론처럼 정상에 올라', startTime: 21, endTime: 24),
    ]),
    DummyTrack(id: '2', title: '봄날', artist: 'BTS', albumArtUrl: '', lyricsTimeline: [
      LyricLine(text: '보고 싶다 이렇게 말하니까 더', startTime: 0, endTime: 3),
      LyricLine(text: '보고 싶다 너희 사진을 보고 있어도', startTime: 3, endTime: 6),
      LyricLine(text: '보고 싶다 너무 야속한 시간', startTime: 6, endTime: 9),
      LyricLine(text: '나는 우리가 밉다', startTime: 9, endTime: 12),
      LyricLine(text: '이제 겨울이 지나고 봄날이 올 때까지', startTime: 12, endTime: 15),
      LyricLine(text: '꽃 피울 때까지 그곳에 좀 더 머물러줘', startTime: 15, endTime: 18),
      LyricLine(text: '머물러줘', startTime: 18, endTime: 21),
      LyricLine(text: '널 잊기엔 아직 너무 많은 날들이', startTime: 21, endTime: 24),
    ], translationTimeline: [
      LyricLine(
          text: 'I miss you, saying this makes me miss you even more',
          startTime: 0,
          endTime: 3),
      LyricLine(
          text: 'I miss you, even though I\'m looking at your picture',
          startTime: 3,
          endTime: 6),
      LyricLine(text: 'I miss you, time is so cruel', startTime: 6, endTime: 9),
      LyricLine(text: 'I hate us', startTime: 9, endTime: 12),
      LyricLine(
          text: 'Until the winter passes and spring comes again',
          startTime: 12,
          endTime: 15),
      LyricLine(
          text: 'Until the flowers bloom, please stay there a little longer',
          startTime: 15,
          endTime: 18),
      LyricLine(text: 'Stay there', startTime: 18, endTime: 21),
      LyricLine(
          text: 'There are still too many days to forget you',
          startTime: 21,
          endTime: 24),
    ]),
    DummyTrack(id: '3', title: 'Lover Boy', artist: 'Phum Viphurit', albumArtUrl: '', lyricsTimeline: [
      LyricLine(text: 'เธอคือความฝันที่ฉันตามหา', startTime: 0, endTime: 3),
      LyricLine(text: 'ในวันที่ฟ้าหม่นหมอง', startTime: 3, endTime: 6),
      LyricLine(text: 'เธอคือแสงสว่างในใจ', startTime: 6, endTime: 9),
    ], translationTimeline: [
      LyricLine(text: 'You are the dream that I have been searching for,', startTime: 0, endTime: 3),
      LyricLine(text: 'On days when the sky is gloomy,', startTime: 3, endTime: 6),
      LyricLine(text: 'You are the light in my heart.', startTime: 6, endTime: 9),
    ]),
  ];

  int _currentIndex = 0;
  final _controller = StreamController<DummyTrack>.broadcast();
  bool _isInitialized = false;
  Timer? _lyricsTimer;
  int _currentLyricIndex = 0;
  final _lyricsController = StreamController<CurrentLyricData>.broadcast();

  DummySpotifyService() {
    // 초기화 지연
    Future.delayed(Duration.zero, () {
      _emitCurrent();
      _startLyricsTimer();
      _isInitialized = true;
    });
  }

  void _emitCurrent() {
    if (!_controller.isClosed) {
      _controller.add(_dummyTracks[_currentIndex]);
    }
  }

  void _startLyricsTimer() {
    _currentLyricIndex = 0;
    _emitCurrentLyric();

    _lyricsTimer?.cancel();
    _lyricsTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final currentTrack = _dummyTracks[_currentIndex];
      _currentLyricIndex =
          (_currentLyricIndex + 1) % currentTrack.lyricsTimeline.length;
      _emitCurrentLyric();
    });
  }

  void _emitCurrentLyric() {
    if (!_lyricsController.isClosed) {
      final currentTrack = _dummyTracks[_currentIndex];
      _lyricsController.add(
        CurrentLyricData(
          lyrics: currentTrack.lyricsTimeline[_currentLyricIndex].text,
          translation:
              currentTrack.translationTimeline[_currentLyricIndex].text,
        ),
      );
    }
  }

  Stream<DummyTrack> get currentTrackStream => _controller.stream;
  Stream<CurrentLyricData> get currentLyricStream => _lyricsController.stream;
  int get currentLyricIndex => _currentLyricIndex;

  void nextTrack() {
    if (!_isInitialized) return;

    _currentIndex = (_currentIndex + 1) % _dummyTracks.length;
    _emitCurrent();
    _currentLyricIndex = 0;
    _startLyricsTimer();
  }

  void dispose() {
    _lyricsTimer?.cancel();
    _controller.close();
    _lyricsController.close();
  }
}

class CurrentLyricData {
  final String lyrics;
  final String translation;

  CurrentLyricData({
    required this.lyrics,
    required this.translation,
  });
}

class DummyTrack {
  final String id;
  final String title;
  final String artist;
  final String albumArtUrl;
  final List<LyricLine> lyricsTimeline;
  final List<LyricLine> translationTimeline;

  DummyTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArtUrl,
    required this.lyricsTimeline,
    required this.translationTimeline,
  });

  String get lyrics => lyricsTimeline.isNotEmpty ? lyricsTimeline[0].text : '';
  String get translation =>
      translationTimeline.isNotEmpty ? translationTimeline[0].text : '';
}
