import 'package:flutter/material.dart';
import '../services/dummy_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _spotifyService = DummySpotifyService();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _spotifyService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가사 번역기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _error = null);
              _spotifyService.nextTrack();
            },
          ),
        ],
      ),
      body: StreamBuilder<DummyTrack>(
        stream: _spotifyService.currentTrackStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final track = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${track.title} - ${track.artist}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text('가사:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(track.lyrics),
                const SizedBox(height: 16),
                Text('번역:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(track.translation),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading
            ? null
            : () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _spotifyService.nextTrack();
                setState(() => _isLoading = false);
              },
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.skip_next),
      ),
    );
  }
}
