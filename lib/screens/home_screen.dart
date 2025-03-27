import 'package:flutter/material.dart';
import '../services/spotify_service.dart';
import '../services/lyrics_service.dart';
import '../services/translate_service.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpotifyService _spotifyService = SpotifyService();
  final LyricsService _lyricsService = LyricsService();
  final TranslateService _translateService = TranslateService();

  String? currentTrack;
  String? originalLyrics;
  String? translatedLyrics;
  bool isLoading = false;
  Timer? _trackCheckTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _trackCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _spotifyService.authenticate();
      if (success) {
        await _startTrackMonitoring();
      } else {
        _showError('Spotify 인증에 실패했습니다.');
      }
    } catch (e) {
      _showError('초기화 중 오류 발생: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _startTrackMonitoring() async {
    await _updateCurrentTrack();
    _trackCheckTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCurrentTrack(),
    );
  }

  Future<void> _updateCurrentTrack() async {
    final trackInfo = await _spotifyService.getCurrentTrack();
    if (trackInfo != null) {
      final newTrackName = '${trackInfo['name']} - ${trackInfo['artist']}';
      if (currentTrack != newTrackName) {
        setState(() {
          currentTrack = newTrackName;
          originalLyrics = null;
          translatedLyrics = null;
        });
        await _fetchAndTranslateLyrics(
            trackInfo['name']!, trackInfo['artist']!);
      }
    }
  }

  Future<void> _fetchAndTranslateLyrics(String trackName, String artist) async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final lyrics = await _lyricsService.fetchLyrics(trackName, artist);
      if (lyrics != null) {
        setState(() => originalLyrics = lyrics);

        final translation = await _translateService.translateText(lyrics, 'ko');
        if (translation != null) {
          setState(() => translatedLyrics = translation);
          _showTranslationPopup(translation);
        }
      } else {
        _showError('가사를 찾을 수 없습니다.');
      }
    } catch (e) {
      _showError('가사 처리 중 오류 발생: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showTranslationPopup(String translation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('번역된 가사'),
        content: SingleChildScrollView(
          child: Text(translation),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스포티파이 가사 번역기'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeApp,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentTrack != null) ...[
            _buildTrackInfo(),
            const SizedBox(height: 24),
          ],
          if (originalLyrics != null) ...[
            _buildLyricsSection(),
          ],
          if (currentTrack == null)
            const Center(
              child: Text('재생 중인 트랙이 없습니다.'),
            ),
        ],
      ),
    );
  }

  Widget _buildTrackInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '현재 재생 중:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          currentTrack!,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildLyricsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '원본 가사:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(originalLyrics!),
            ),
          ),
          const SizedBox(height: 16),
          if (translatedLyrics != null)
            ElevatedButton(
              onPressed: () => _showTranslationPopup(translatedLyrics!),
              child: const Text('번역된 가사 보기'),
            ),
        ],
      ),
    );
  }
}
