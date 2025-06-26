import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import '../widgets/transparent_lyric_widget.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/spotify_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    context.read<SpotifyBloc>().add(LoadCurrentTrack());
  }

  @override
  void dispose() {
    _animationController.dispose();
    FlutterOverlayWindow.closeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<SpotifyBloc, SpotifyState>(
        builder: (context, state) {
          if (state is SpotifyInitial || state is SpotifyLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Spotify 연결 중...', style: TextStyle(color: Colors.white)),
                ],
              ),
            );
          } else if (state is SpotifyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('오류: ${state.message}', 
                       style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SpotifyBloc>().add(LoadCurrentTrack());
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          } else if (state is SpotifyNoTrack) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note, color: Colors.grey, size: 48),
                  SizedBox(height: 16),
                  Text('재생 중인 곡이 없습니다', 
                       style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Spotify에서 음악을 재생해주세요', 
                       style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          } else if (state is SpotifyLoaded) {
            final currentTrack = state.currentTrack;
            final currentLyric = state.currentLyric;
            final currentTranslation = state.currentTranslation;

            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted && currentLyric.isNotEmpty) {
                FlutterOverlayWindow.showOverlay(
                  height: 200,
                  width: 400,
                  startPosition: OverlayPosition(0, MediaQuery.of(context).size.height - 200),
                  overlayTitle: '가사 번역 중',
                  overlayContent: currentLyric,
                  enableDrag: true,
                );
                FlutterOverlayWindow.shareData({
                  'lyric': currentLyric,
                  'translation': currentTranslation,
                });
              }
            });

            return Stack(
              children: [
                Container(
                  color: Colors.black,
                ),

                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (currentTrack.albumArtUrl.isNotEmpty)
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              image: DecorationImage(
                                image: NetworkImage(currentTrack.albumArtUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTrack.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                currentTrack.artist,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          currentTrack.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.125 * ((0 % 8) + 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey<String>('$currentLyric-$currentTranslation'),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (currentLyric.isNotEmpty) ...[
                              Text(
                                currentLyric,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                              if (currentTranslation.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Divider(
                                    color: Colors.white24,
                                    height: 16,
                                  ),
                                ),
                                Text(
                                  currentTranslation,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ],
                            ] else ...[
                              const Text(
                                '가사를 불러오는 중...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
