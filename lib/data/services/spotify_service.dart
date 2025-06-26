import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/spotify_track.dart';
import '../../domain/entities/lyric_data.dart';

class SpotifyService {
  static const String _baseUrl = 'https://api.spotify.com/v1';
  static const String _authUrl = 'https://accounts.spotify.com';
  static const String _redirectUri = 'http://localhost:8080/callback';

  final String clientId = dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
  final String clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET'] ?? '';

  String? _accessToken;
  String? _refreshToken;
  Timer? _tokenRefreshTimer;
  Timer? _trackCheckTimer;
  
  // 이전 곡 ID를 저장하여 중복 API 호출 방지
  String? _previousTrackId;
  
  final StreamController<SpotifyTrack?> _trackController = StreamController<SpotifyTrack?>.broadcast();
  final StreamController<LyricData> _lyricController = StreamController<LyricData>.broadcast();
  
  bool _isInitialized = false;

  SpotifyService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await dotenv.load();
    await _authenticate();
    _startTokenRefreshTimer();
    _startTrackCheckTimer();
    _isInitialized = true;
  }

  Future<void> _authenticate() async {
    try {
      final clientId = dotenv.env['SPOTIFY_CLIENT_ID'];
      final clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET'];
      
      if (clientId == null || clientSecret == null) {
        throw Exception('Spotify API 키가 설정되지 않았습니다. .env 파일을 확인하세요.');
      }

      // Client Credentials Flow 사용 (공개 API 접근용)
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        },
        body: {
          'grant_type': 'client_credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        print('Spotify 인증 성공');
      } else {
        throw Exception('Spotify 인증 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('Spotify 인증 오류: $e');
      rethrow;
    }
  }

  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    // 토큰은 1시간마다 갱신
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 55), (timer) {
      _authenticate();
    });
  }

  void _startTrackCheckTimer() {
    _trackCheckTimer?.cancel();
    // 10초마다 현재 재생 중인 곡 확인
    _trackCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkCurrentTrack();
    });
  }

  Future<void> _checkCurrentTrack() async {
    if (!_isInitialized || _accessToken == null) return;

    try {
      // 현재 재생 중인 곡 정보 가져오기
      final response = await http.get(
        Uri.parse('$_baseUrl/me/player/currently-playing'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data != null && data['item'] != null) {
          final trackId = data['item']['id'];
          
          // 새로운 곡인지 확인
          if (trackId != _previousTrackId) {
            _previousTrackId = trackId;
            
            final track = SpotifyTrack(
              id: trackId,
              title: data['item']['name'],
              artist: data['item']['artists'][0]['name'],
              albumArtUrl: data['item']['album']['images'][0]['url'],
              isPlaying: data['is_playing'] ?? false,
            );
            
            _trackController.add(track);
            
            // 가사 검색 및 번역 시작
            await _fetchAndTranslateLyrics(track);
          }
        } else {
          // 재생 중인 곡이 없음
          _trackController.add(null);
        }
      } else if (response.statusCode == 401) {
        // 토큰 만료, 재인증
        await _authenticate();
      }
    } catch (e) {
      print('현재 곡 확인 오류: $e');
    }
  }

  Future<void> _fetchAndTranslateLyrics(SpotifyTrack track) async {
    try {
      print('가사 검색 중: ${track.artist} - ${track.title}');
      
      // Genius API를 통한 가사 검색 (실제 구현에서는 Genius API 키 필요)
      final lyrics = await _searchLyrics(track.title, track.artist);
      
      if (lyrics.isNotEmpty) {
        // 번역 서비스를 통한 번역
        final translation = await _translateLyrics(lyrics);
        
        final lyricData = LyricData(
          lyrics: lyrics,
          translation: translation,
          timestamp: DateTime.now(),
        );
        
        _lyricController.add(lyricData);
      } else {
        print('가사를 찾을 수 없습니다: ${track.title}');
      }
    } catch (e) {
      print('가사 처리 오류: $e');
    }
  }

  Future<String> _searchLyrics(String title, String artist) async {
    try {
      // 실제 구현에서는 Genius API를 사용해야 합니다
      // 여기서는 더미 가사를 반환합니다
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
      
      // 더미 가사 데이터
      final dummyLyrics = {
        'Dynamite': 'Cause I-I-I\'m in the stars tonight\nSo watch me bring the fire and set the night alight',
        '봄날': '보고 싶다 이렇게 말하니까 더\n보고 싶다 너희 사진을 보고 있어도',
        'Lover Boy': 'เธอคือความฝันที่ฉันตามหา\nในวันที่ฟ้าหม่นหมอง',
      };
      
      return dummyLyrics[title] ?? '가사를 찾을 수 없습니다.';
    } catch (e) {
      print('가사 검색 오류: $e');
      return '';
    }
  }

  Future<String> _translateLyrics(String lyrics) async {
    try {
      // 실제 구현에서는 Google Translate API를 사용해야 합니다
      // 여기서는 더미 번역을 반환합니다
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
      
      final dummyTranslations = {
        'Cause I-I-I\'m in the stars tonight\nSo watch me bring the fire and set the night alight': 
        '난 오늘 밤 별들 사이에 있으니\n내가 불을 지피고 밤을 밝히는 걸 지켜봐',
        '보고 싶다 이렇게 말하니까 더\n보고 싶다 너희 사진을 보고 있어도':
        'I miss you, saying this makes me miss you even more\nI miss you, even though I\'m looking at your picture',
        'เธอคือความฝันที่ฉันตามหา\nในวันที่ฟ้าหม่นหมอง':
        'You are the dream that I have been searching for\nOn days when the sky is gloomy',
      };
      
      return dummyTranslations[lyrics] ?? '[번역] $lyrics';
    } catch (e) {
      print('번역 오류: $e');
      return '[번역 오류] $lyrics';
    }
  }

  Stream<SpotifyTrack?> get currentTrackStream => _trackController.stream;
  Stream<LyricData> get currentLyricStream => _lyricController.stream;

  void dispose() {
    _tokenRefreshTimer?.cancel();
    _trackCheckTimer?.cancel();
    _trackController.close();
    _lyricController.close();
  }
}
