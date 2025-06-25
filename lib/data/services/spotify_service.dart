import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotifyService {
  static const String _baseUrl = 'https://api.spotify.com/v1';
  static const String _authUrl = 'https://accounts.spotify.com';
  static const String _redirectUri = 'http://localhost:8080/callback';

  final String clientId = dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
  final String clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET'] ?? '';

  String? _accessToken;
  String? _refreshToken;

  // 테스트용 더미 데이터
  bool _isDemoMode = true;
  int _demoTrackIndex = 0;
  final List<Map<String, String>> _demoTracks = [
    {
      'name': 'Shape of You',
      'artist': 'Ed Sheeran',
      'lyrics':
          'The club isn\'t the best place to find a lover\nSo the bar is where I go...',
    },
    {
      'name': 'Dynamite',
      'artist': 'BTS',
      'lyrics':
          'Cause I-I-I\'m in the stars tonight\nSo watch me bring the fire and set the night alight...',
    },
    {
      'name': 'Butter',
      'artist': 'BTS',
      'lyrics': 'Smooth like butter\nLike a criminal undercover...',
    },
  ];

  bool get isAuthenticated => _accessToken != null;

  Future<bool> authenticate() async {
    if (_isDemoMode) {
      return true;
    }
    return false;
  }

  Future<Map<String, String>?> getCurrentTrack() async {
    if (_isDemoMode) {
      // 데모 모드에서는 5초마다 다른 곡을 반환
      await Future.delayed(const Duration(seconds: 5));
      final track = _demoTracks[_demoTrackIndex];
      _demoTrackIndex = (_demoTrackIndex + 1) % _demoTracks.length;
      return {
        'name': track['name']!,
        'artist': track['artist']!,
        'lyrics': track['lyrics']!,
      };
    }
    return null;
  }

  // 프로덕션 모드로 전환
  void disableDemoMode() {
    _isDemoMode = false;
  }
}
