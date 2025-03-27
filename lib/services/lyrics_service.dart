import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LyricsService {
  static const String _baseUrl = 'api.musixmatch.com';
  final String apiKey = dotenv.env['MUSIXMATCH_API_KEY'] ?? '';

  Future<String?> fetchLyrics(String trackName, String artistName) async {
    try {
      final trackId = await _searchTrack(trackName, artistName);
      if (trackId == null) return null;

      return await _getLyrics(trackId);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching lyrics: $e');
      }
      return null;
    }
  }

  Future<String?> _searchTrack(String trackName, String artistName) async {
    final searchUri = Uri.https(_baseUrl, '/ws/1.1/track.search', {
      'q_track': trackName,
      'q_artist': artistName,
      'apikey': apiKey,
      'page_size': '1',
      's_track_rating': 'desc',
    });

    final response = await http.get(searchUri);
    final data = jsonDecode(response.body);

    if (_isValidResponse(data) && _hasTracks(data)) {
      return data['message']['body']['track_list'][0]['track']['track_id']
          .toString();
    }
    return null;
  }

  Future<String?> _getLyrics(String trackId) async {
    final lyricsUri = Uri.https(_baseUrl, '/ws/1.1/track.lyrics.get', {
      'track_id': trackId,
      'apikey': apiKey,
    });

    final response = await http.get(lyricsUri);
    final data = jsonDecode(response.body);

    if (_isValidResponse(data)) {
      final lyrics = data['message']['body']['lyrics']['lyrics_body'];
      return _cleanLyrics(lyrics);
    }
    return null;
  }

  bool _isValidResponse(Map<String, dynamic> data) {
    return data['message']['header']['status_code'] == 200;
  }

  bool _hasTracks(Map<String, dynamic> data) {
    return data['message']['body']['track_list'].isNotEmpty;
  }

  String _cleanLyrics(String lyrics) {
    // 상업적 사용 문구 제거
    return lyrics.replaceAll(RegExp(r'\*+.*\*+'), '').trim();
  }
}
